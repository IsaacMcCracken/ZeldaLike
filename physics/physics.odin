package physics


import "core:fmt"
import "core:math"
import glm "core:math/linalg/glsl"

Vec2 :: glm.vec2
Vec3 :: glm.vec3
Vec4 :: glm.vec4

Plane :: struct #raw_union {
  using form: struct {
    normal: Vec3,
    constant: f32,
  },
  equation: Vec4
}

BoundingBox :: struct {
  position: Vec3,
  size: Vec3,
}

Entity :: struct {
  position: Vec3,
  velocity: Vec3,
  radius: f32, // sphere collsion
  mass: f32
}

Collision :: struct {
  intersection: Vec3,
  normal: Vec3,
}


plane_from_triangle :: proc(tri:  [3]Vec3) -> Plane {
  normal := glm.normalize(glm.cross(tri[1] - tri[0], tri[2] - tri[0]))
  origin := tri[0]
  

  return Plane {
    form = {
      normal = normal,
      constant = -glm.dot(normal, origin),
    }
  }
}

plane_is_front_facing_to :: proc(plane: Plane, dir: Vec3) -> bool {
  dot := glm.dot(plane.normal, dir)

  return dot <= 0
}

plane_signed_distance :: proc(plane: Plane, p: Vec3) -> f32 {
  return glm.dot(plane.normal, p) + plane.constant
}

point_in_triangle :: proc(v: Vec3, triangle: [3]Vec3) -> bool {
  // gonna be honest do not know what is up right here
  e1 := triangle[1] - triangle[0]
  e2 := triangle[2] - triangle[0]

  a := glm.dot(e1, e1)
  b := glm.dot(e1, e2)
  c := glm.dot(e2, e2)

  ac_bb := (a*c)-(b*b)
  vp := Vec3{v.x - triangle[0].x, v.y - triangle[0].y, v.z - triangle[0].z}

  d := glm.dot(vp, e1)
  e := glm.dot(vp, e2)
  x := (d*c) - (e*b)
  y := (e*a) - (d*b)
  z := x + y - ac_bb

  // another crazy evil bit hack?
  return ((transmute(u32)z & ~(transmute(u32)x|transmute(u32)y) & 0x80000000)) > 0
}


@(require_results)
collision_sphere_triangle :: proc(e: ^Entity, triangle: [3]Vec3) -> (col: Collision, collide: bool) {
  // were gonna need to clean this up quite a bit

  // Convert To Sphere space
  base_pos := e.position/e.radius
  vel_norm := glm.normalize(e.velocity)/e.radius
  vel := e.velocity/e.radius
  tri := triangle/e.radius

  plane := plane_from_triangle(tri) 

  col.normal = plane.normal

  

  if !plane_is_front_facing_to(plane, vel_norm) do return
  t0, t1: f32
  inside_plane := false 

  // calculate the signed distance from plane
  signed_distance := plane_signed_distance(plane, base_pos)

  // Cashe this:
  norm_dot_vel := glm.dot(plane.normal, vel)

  // we do not want to divde by zero so yeah (but i heard its kinda based)
  if norm_dot_vel == 0 {
    // we are not in the plane so a collision is not possible
    if abs(signed_distance) >= 1 do return // false
    
    inside_plane = true
    t0 = 0
    t1 = 1

  } else {
    t0 = (-1-signed_distance)/norm_dot_vel
    t1 = (1-signed_distance)/norm_dot_vel

    // swap so we can only do one comparision
    if t0 > t1 do t0, t1 = t1, t0
    // if the values arent in range[0,1] no collsion is possible
    if t0 > 1 || t1 < 0 do return // false


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
      // found_collision = true
      // t = t0
      collide = true
      col.intersection = plane_intersection
      return
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
      col.intersection = p
    }
  }

  // now we check for the edges
  for _, i in tri {
    j := (i + 1)%3
    edge := tri[i] - tri[j]
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
        // t = tnew
        // found_collision = true

        collide = true
        col.intersection = tri[i] + f*edge
        return
      }
    }


  }
  
  

  return
}

collide_and_slide :: proc(e: ^Entity, triangle: [3]Vec3) {
  
} 