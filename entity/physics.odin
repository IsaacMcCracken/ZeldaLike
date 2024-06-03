package entity

import rl "vendor:raylib"

update_physics :: proc(e: ^Entity) {
  if e.position.y < 0.5 {
    e.position.y = 0.5
    e.velocity.y *= -0.99
  }
  e.velocity.y -= 0.025
  e.position += e.velocity
}