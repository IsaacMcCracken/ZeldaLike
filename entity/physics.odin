package entity

import rl "vendor:raylib"
import "core:fmt"


Plane :: struct #raw_union {
  using form: struct {
    normal: Vector3,
    constant: f32,
  },
  equation: Vector4
}


CollisionData :: struct {
  intersection: Vector3,
}


PhysicsData :: struct {
  ellipsoid: Vector3,
  position: Vector3,
  velocity: Vector3
}

update_physics :: proc(e: ^Entity, dt: f32) {
  if e.position.y < 0.5 {
    e.position.y = 0.5
    e.velocity.y *= -0.99
  }
  e.velocity.y -= 0.025

  e.position += e.velocity
}


plane_from_triangle :: proc(triangle:  [3]Vector3) -> Plane {
  normal := rl.Vector3Normalize(rl.Vector3CrossProduct(triangle[1]-triangle[0], triangle[2]-triangle[0]))
  origin := triangle[0]
  

  return Plane {
    form = {
      normal = normal,
      constant = -rl.Vector3DotProduct(normal, origin),
    }
  }

}

plane_signed_distance_to :: proc(plane: Plane, p: Vector3) -> f32 {
  return rl.Vector3DotProduct(p, plane.normal) + plane.constant
}

sweep_ellipsoid_triangle_collision :: proc(data: PhysicsData, triangle: [3]Vector3, dt: f32) -> (CollisionData, bool) {
  // convert to ellipsoid space
  triangle := triangle
  data := data
  for v, i in triangle do triangle[i] /= data.ellipsoid 
  data.velocity /= data.ellipsoid
  data.position /= data.ellipsoid

  // our result
  collision: CollisionData


  plane := plane_from_triangle(triangle) 
  d := rl.Vector3DotProduct(plane.normal, data.velocity)

  // if d < 0 do return {}, false

  signed_distance := plane_signed_distance_to(plane, data.position)

  // Gotta check for d
  t0, t1: f32

  t0 = (1-signed_distance)/d
  t1 = (-1-signed_distance)/d

  if rl.IsKeyDown(.O) do fmt.println(t0, t1, signed_distance, d, plane)

  p := data.position - plane.normal + t0*data.velocity
  if !((0 <= t0 && t0 <= 1) || (0 <= t1 && t1 <= 1)) do return {}, false

  if !check_point_in_triangle(p, triangle) do return {}, false

  collision.intersection = p
  return collision, true
}

check_point_in_triangle :: proc(v: Vector3, triangle: [3]Vector3) -> bool {
  // gonna be honest do not know what is up right here
  e1 := triangle[1] - triangle[0]
  e2 := triangle[2] - triangle[0]

  a := rl.Vector3DotProduct(e1, e1)
  b := rl.Vector3DotProduct(e1, e2)
  c := rl.Vector3DotProduct(e2, e2)

  ac_bb := (a*c)-(b*b)
  vp := Vector3{v.x - triangle[0].x, v.y - triangle[0].y, v.z - triangle[0].z}

  d := rl.Vector3DotProduct(vp, e1)
  e := rl.Vector3DotProduct(vp, e2)
  x := (d*c) - (e*b)
  y := (e*a) - (d*b)
  z := x + y - ac_bb

  // another crazy evil bit hack?
  return ((transmute(u32)z & ~(transmute(u32)x|transmute(u32)y) & 0x80000000)) > 0
}

sweep_plane_elipsoid_intersection :: proc(plane: Plane, p: Vector3) {
  
}