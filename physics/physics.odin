package physics

import rl "vendor:raylib"

import "core:fmt"
import "core:slice"
import "core:math"
import glm "core:math/linalg/glsl"

Mesh :: rl.Mesh

Vec2 :: glm.vec2
Vec3 :: glm.vec3
Vec4 :: glm.vec4

Quat :: rl.Quaternion
Transform :: rl.Transform



// change the mesh to some kind of world structure
collide_and_slide :: proc(e: ^Entity, mesh: Mesh) {
  // temporary
  dir: Vec3
  if rl.IsKeyDown(.W) do dir.z -= 1
  if rl.IsKeyDown(.S) do dir.z += 1
  if rl.IsKeyDown(.D) do dir.x += 1
  if rl.IsKeyDown(.A) do dir.x -= 1
  // if rl.IsKeyDown(.LEFT_SHIFT) do dir.y -= 1
  // if rl.IsKeyDown(.SPACE) do dir.y += 1

  if dir != {0,0,0} do dir = glm.normalize(dir)
  // vel = glm.normalize(vel)
  dir *= 0.5
  
  e.velocity.x = dir.x  
  e.velocity.z = dir.z
  e.velocity.y -= 0.05

  if rl.IsKeyPressed(.SPACE) do e.velocity += 1


  // convert to sphere space
  s_position := e.position/e.radius
  s_velocity := e.velocity/e.radius

  pos, vel, col := collide_with_world(e.radius, s_position, s_velocity, mesh, 0)

  // pos, vel, col := collide_with_world(e.radius, s_position, dir, mesh, 0)



  e.position = pos*e.radius
  e.velocity = vel*e.radius
}

collide_with_world :: proc(radius: f32, position, velocity: Vec3, mesh: Mesh, depth: u32) -> (pos, vel: Vec3, col: Collision) {
  VERY_CLOSE_DISTANCE :: 0.0000005
  
  if depth > 6 {
    vel = velocity
    pos = position
    return
  }

  col = collide_with_mesh(radius, position, velocity, mesh)

  destination := position + velocity

  if col.kind == .None {
    vel = velocity
    pos = destination
    return
  }

  
  // only update if we are not already very close to the intersection point
  
  
  // determine the sliding plane
  new_destination := position + velocity * col.t 
  normal := glm.normalize(new_destination - col.intersection)
  plane := plane_make(col.intersection, normal)
  new_velocity := plane_projection(velocity, plane)
  
  fmt.println(col, "Normal", normal)

  new_destination += VERY_CLOSE_DISTANCE * normal

  pos, vel, col = collide_with_world(radius, new_destination, new_velocity, mesh, depth + 1)

  // if col2.kind != .None {
  //   col = col2
  //   pos = pos2  
  //   vel = vel2
  // }

  return
}

collide_with_mesh :: proc(radius: f32, position, velocity: Vec3, mesh: Mesh) -> (col: Collision) {
  col.distance = math.inf_f32(1)

  vertices := slice.reinterpret([]Vec3, mesh.vertices[:3 * mesh.vertexCount])

  if mesh.indices != nil {

    indices := slice.reinterpret([][3]u16, mesh.indices[:3 * mesh.triangleCount])
  
    for triangle_indices in indices {
      // find and convert triangle to sphere space
      triangle := [3]Vec3{vertices[triangle_indices[0]], vertices[triangle_indices[1]], vertices[triangle_indices[2]]}/radius
  
      cur_col := collision_sphere_triangle(position, velocity, triangle)
  
      if cur_col.kind != .None && cur_col.distance < col.distance {
        assert(col.t >= 0 && col.t <= 1)
        col = cur_col
      }
    }
  } else {
    triangles := slice.reinterpret([][3]Vec3, vertices)

    for triangle in triangles {
      tri := triangle/radius

      cur_col := collision_sphere_triangle(position, velocity, tri)
  
      if cur_col.kind != .None && cur_col.distance < col.distance {
        col = cur_col
      }
    }
  }


  return
}

@(require_results)
collision_sphere_triangle :: proc(position, velocity: Vec3, triangle: [3]Vec3) -> Collision {
  // were gonna need to clean this up quite a bit

  // Convert To Sphere space 
  vel_norm := glm.normalize(velocity) // we will see if this is neccessary


  plane := plane_from_triangle(triangle) 


  

  if !plane_is_front_facing_to(plane, vel_norm) do return {}
  t0, t1: f32
  inside_plane := false 

  // calculate the signed distance from plane
  signed_distance := plane_signed_distance(plane, position)

  // Cashe this:
  norm_dot_vel := glm.dot(plane.normal, velocity )

  // we do not want to divde by zero so yeah (but i heard its kinda based)
  if norm_dot_vel == 0 {
    // we are not in the plane so a collision is not possible
    if abs(signed_distance) >= 1 do return {} // false
    
    inside_plane = true
    t0 = 0
    t1 = 1

  } else {
    t0 = (-1-signed_distance)/norm_dot_vel
    t1 = (1-signed_distance)/norm_dot_vel

    // swap so we can only do one comparision
    if t0 > t1 do t0, t1 = t1, t0
    // if the values arent in range[0,1] no collsion is possible
    if t0 > 1 || t1 < 0 do return {} // false


    // idk we we clamping but lets do it
    t0 = clamp(t0, 0, 1)
    t1 = clamp(t1, 0, 1)
  }

  // Okay so at this point we have a confirmed collsion with the plane
  // but not with the triangle so we will check that I guess

  // col.intersection: Vec3
  // found_collision := false
  t := f32(1)



  // first we must check the easy case to see if the swept sphere intersects
  // the triangle which will be most of our cases. If it happens it must happen
  // at t0 when the sphere rests on the face of the triangle. But this can only 
  // occur if the sphere is not embedded in the plane. 

  if !inside_plane {
    plane_intersection := (position - plane.normal) + t0 * velocity 
    if point_in_triangle(plane_intersection, triangle) {
      return Collision{
        kind = .Face,
        intersection = plane_intersection,
        distance = glm.length(t0 * velocity),
        t = t0,
      }
    }
  }


  // if we have not found out colision already then we will have to sweep our  
  // triangle against the edges and vertices now.

  vel_len_sqr := len_sqr(velocity )
  a, b, c, t_prime: f32

  // for each vertext or edge a qudratic equation has to be solved
  a = len_sqr(velocity )
  for p in triangle {
    b = 2*(glm.dot(velocity , position - p))
    c = len_sqr(p - position) - 1
    if tnew, ok := root_lowest(a, b, c); ok {
      if tnew < 0 || tnew > 1 do continue
      return {
        kind = .Vertex,
        intersection = p,
        distance = glm.length(tnew * velocity),
        t = tnew
      }
    }
  }

  // now we check for the edges
  for _, i in triangle {
    j := (i + 1)%3
    edge := triangle[j] - triangle[i]
    base_to_vertex := triangle[i] - position
    edge_len_sqr := len_sqr(edge)
    edge_dot_vel := glm.dot(edge, velocity )
    edge_dot_base_to_vertex := glm.dot(edge, base_to_vertex)


    a = edge_len_sqr * -vel_len_sqr + edge_dot_vel* edge_dot_vel
    b = edge_len_sqr * 2*(glm.dot(velocity, base_to_vertex)) - 2*(edge_dot_vel * edge_dot_vel)
    c = edge_len_sqr * (1 - len_sqr(base_to_vertex)) + edge_dot_base_to_vertex * edge_dot_base_to_vertex

    if tnew, ok := root_lowest(a, b, c); ok {
      if tnew < 0 || tnew > 1 do continue
 
      f := (edge_dot_vel * tnew - edge_dot_base_to_vertex)/edge_len_sqr

      if f >= 0 && f <= 1 {
        return {
          kind = .Edge,
          intersection = triangle[i] + f*edge,
          distance = glm.length(tnew * velocity),
          t = tnew,
        }
      }
    }


  }
  
  

  return {} // I dont think this can happen but we will see
}

