package entity

// vendor
import rl "vendor:raylib"

// core
import "core:fmt"
import list "core:container/intrusive/list"

// game
import "../physics"


Flags :: bit_set[Flag; u64]
Flag :: enum {
  Controllable,
  Physics,
}

Entity :: struct {
  using physics: physics.Entity,
  using link: list.Node,
  flags: Flags,
}

Manager :: struct {
  entities: list.List,
  free_list: list.List,
}


Iterator :: struct {
  current: ^Entity,
  next: ^Entity,
}

iterater_from_start :: proc(m: ^Manager) -> Iterator {
  current, next: ^Entity

  current = container_of(m.entities.head, Entity, "link")
  if current != nil do next = container_of(current.next, Entity, "link")


  return Iterator {
    current = current,
    next = next
  }
}

iterate_next :: proc(it: ^Iterator) -> (^Entity, bool) {
  res := it.current

  if it.current != nil do it.current = container_of(it.current.next, Entity, "link")
  if it.next != nil do it.current = container_of(it.current.next, Entity, "link")

  return res, it.current != nil
}

