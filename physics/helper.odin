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