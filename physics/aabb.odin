package physics

import glm "core:/math/linalg/glsl"

BoundingBox :: struct {
  upper, lower: Vec3,
}


bounding_box_union :: proc "contextless" (a, b: BoundingBox) -> BoundingBox {
  upper, lower: Vec3
  upper.x = max(a.upper.x, b.upper.x)
  upper.y = max(a.upper.y, b.upper.y)
  upper.z = max(a.upper.z, b.upper.z)

  lower.x = min(a.lower.x, b.lower.x)
  lower.y = min(a.lower.y, b.lower.y)
  lower.z = min(a.lower.z, b.lower.z)

  return BoundingBox{upper, lower}
}

bounding_box_area :: proc "contextless" (a: BoundingBox) -> f32 {
  d := a.upper - a.lower
  return 2 * glm.dot(d, d.yzx)
}