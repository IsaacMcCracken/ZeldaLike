package physics

// core
import "core:testing"


@(test)
test_sphere_triangle :: proc(_: ^testing.T) {
  e := Entity{
    position  = {0, 2, 3},
    velocity = {0.24, -3, 0},
    radius = 0.75,
  }

  triangle := [3]Vec3{{-5, 0, 5}, {5, 3, 0,}, {-5, 0, -5}}

  col, ok := collision_sphere_triangle(&e, triangle)
}
