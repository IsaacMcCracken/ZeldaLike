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




@(require_results)
collision_sphere_triangle :: proc(position, velocity: Vec3, triangle: [3]Vec3) -> Collision {
  // were gonna need to clean this up quite a bit

  // Convert To Sphere space 
  base_pos := position
  vel_norm := glm.normalize(velocity)
  vel := velocity
  tri := triangle

  plane := plane_from_triangle(tri) 


  

  if !plane_is_front_facing_to(plane, vel_norm) do return {}
  t0, t1: f32
  inside_plane := false 

  // calculate the signed distance from plane
  signed_distance := plane_signed_distance(plane, base_pos)

  // Cashe this:
  norm_dot_vel := glm.dot(plane.normal, vel)

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
    plane_intersection := (base_pos - plane.normal) + t0 * vel
    if point_in_triangle(plane_intersection, tri) {
      return Collision{
        kind = .Face,
        intersection = plane_intersection,
        t = t0,
      }
    }
  }


  // if we have not found out colision already then we will have to sweep our  
  // triangle against the edges and vertices now.

  vel_len_sqr := len_sqr(vel)
  a, b, c, t_prime: f32

  // for each vertext or edge a qudratic equation has to be solved
  a = len_sqr(vel)
  for p in tri {
    b = 2*(glm.dot(vel, base_pos - p))
    c = len_sqr(p - base_pos) - 1
    if tnew, ok := root_lowest(a, b, c); ok {
      return {
        kind = .Vertex,
        intersection = p,
        t = tnew
      }
    }
  }

  // now we check for the edges
  for _, i in tri {
    j := (i + 1)%3
    edge := tri[j] - tri[i]
    base_to_vertex := tri[i] - base_pos
    edge_len_sqr := len_sqr(edge)
    edge_dot_vel := glm.dot(edge, vel)
    edge_dot_base_to_vertex := glm.dot(edge, base_to_vertex)


    a = edge_len_sqr * -vel_len_sqr + edge_dot_vel* edge_dot_vel
    b = edge_len_sqr * 2*(glm.dot(vel, base_to_vertex)) - 2*(edge_dot_vel * edge_dot_vel)
    c = edge_len_sqr * (1 - len_sqr(base_to_vertex)) + edge_dot_base_to_vertex * edge_dot_base_to_vertex

    if tnew, ok := root_lowest(a, b, c); ok {
      f := (edge_dot_vel * tnew - edge_dot_base_to_vertex)/edge_len_sqr

      if f >= 0 && f <= 1 {
        return {
          kind = .Edge,
          intersection = tri[i] + f*edge,
          t = tnew,
        }
      }
    }


  }
  
  

  return {} // I dont think this can happen but we will see
}

collide_and_slide :: proc(e: ^Entity, mesh: Mesh) {

}

VERY_CLOSE_DISTANCE :: 0.00005

collide_and_slide_mesh :: proc(position, velocity: Vec3, mesh: Mesh, depth: u32) -> Vec3 {
  if depth > 5 do return position

  // Check for colision here
  vertices := slice.reinterpret([]Vec3, mesh.vertices[:3*mesh.vertexCount])
  if mesh.indices != nil {
    triangles := slice.reinterpret([][3]u16, mesh.indices[:3*mesh.triangleCount])
    for indices, i in triangles {
      tri := [3]Vec3{vertices[indices[0]], vertices[indices[1]], vertices[indices[2]]}

      col := collision_sphere_triangle(position, velocity, tri)

    }
  }
}

