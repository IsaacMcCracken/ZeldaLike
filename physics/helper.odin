package physics

import "core:math"
import glm "core:math/linalg/glsl"

root_lowest :: proc(a, b, c: f32) -> (x: f32, ok: bool) {
  determinant :=  b*b - 4*a*c

  if determinant < 0 do return

  ok = true

  sqrt_d := math.sqrt(determinant)
  x1 := (-b + sqrt_d)/(2*a)
  x2 := (-b - sqrt_d)/(2*a)

  x = min(x1, x2)


  return
}

len_sqr_vec2 :: proc(v: Vec2) -> f32 {
  return glm.dot(v, v)
}

len_sqr_vec3 :: proc(v: Vec3) -> f32 {
  return glm.dot(v, v)
}

len_sqr_vec4 :: proc(v: Vec4) -> f32 {
  return glm.dot(v, v)
}

len_sqr :: proc{
  len_sqr_vec2,
  len_sqr_vec3,
  len_sqr_vec4}

plane_from_triangle :: proc(tri:  [3]Vec3) -> Plane {
  normal := glm.normalize(glm.cross(tri[1] - tri[0], tri[2] - tri[0]))
  origin := tri[0]
  

  return plane_make(origin, normal)
}

plane_make :: proc(origin, normal: Vec3) -> Plane {
  return Plane {
    form = {
      normal = normal,
      constant = -glm.dot(normal, origin)
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
