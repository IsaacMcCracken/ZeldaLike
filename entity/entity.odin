package entity

// vendor
import rl "vendor:raylib"

// core
import "core:fmt"
import list "core:container/intrusive/list"

// game

Vector2 :: rl.Vector2
Vector3 :: rl.Vector3
Vector4 :: rl.Vector4

Manager :: struct {
  entities: list.List,
  free_list: list.List,
}

Flag :: enum {
  Controllable,
  Physics,
}

Flags :: bit_set[Flag; u64]



Entity :: struct {
  using link: list.Node,
  using physics: PhysicsData,
  flags: Flags,
}



update_controllable :: proc(e: ^Entity, dt: f32) {
  input: Vector3
  if rl.IsKeyDown(.W) do input.z -= 1
  if rl.IsKeyDown(.S) do input.z += 1
  if rl.IsKeyDown(.D) do input.x += 1
  if rl.IsKeyDown(.A) do input.x -= 1

  input = rl.Vector3Normalize(input)
  
  speed :: 0.02

  input *= speed

  e.velocity += input 

  if rl.IsKeyPressed(.V) do fmt.println(e.velocity)
}

update :: proc(m: ^Manager, dt: f32) {
  it := list.iterator_head(m.entities, Entity, "link")

  for e in list.iterate_next(&it) {
    if .Controllable in e.flags do update_controllable(e, dt)
    if .Physics in e.flags do update_physics(e, dt)
  }
}

add_literal :: proc(m: ^Manager, e: ^Entity) {
  list.push_back(&m.entities, &e.link)
}