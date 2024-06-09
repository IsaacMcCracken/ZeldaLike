package physics

Entity :: struct {
  position: Vec3,
  velocity: Vec3,
  radius: f32, // sphere collsion
  mass: f32
}

Plane :: struct #raw_union {
  using form: struct {
    normal: Vec3,
    constant: f32,
  },
  equation: Vec4
}

Collision :: struct {
  kind: CollisionKind,
  intersection: Vec3,
  t: f32,
}

CollisionKind :: enum u8 {
  None,
  Entity,
  Face,
  Vertex,
  Edge,
}