package game

// Vendor Packages
import rl "vendor:raylib"
// Core Packages
import glm "core:math/linalg/glsl "
// Game Packages
import "entity"
import "physics"


main :: proc () {
  rl.InitWindow(800, 800, "Zelda Engine")
  camera := rl.Camera{
    target = {0, 0, 0},
    position = {0, 6, 8},
    up = {0, 1, 0},
    fovy = 90,

  }

  player := physics.Entity{
    position = {0, 3, 0},
    radius = 1,
  }

  tri := [3]physics.Vec3{{-5, 0, 5}, {5, 3, 0,}, {-5, 0, -5}}

  rl.SetTargetFPS(60)
  for !rl.WindowShouldClose() {
    player.position += player.velocity

    if col, ok := physics.collision_sphere_triangle(&player, tri); ok {
      player.velocity = glm.reflect(player.velocity, col.normal)
    } else {
      player.velocity.y -= 0.05 * rl.GetFrameTime()
    }

    rl.UpdateCamera(&camera, .ORBITAL)


    if rl.IsKeyPressed(.R) {
      player.velocity = {}
      player.position = {0, 5, 0}
    }
    drawing: {
      rl.BeginDrawing()
      defer rl.EndDrawing()

      rl.ClearBackground(rl.BLACK)
      mode3d: {
        rl.BeginMode3D(camera)
        defer rl.EndMode3D()
  
        rl.DrawSphere(player.position, player.radius, rl.GREEN)
        rl.DrawTriangle3D(tri[0], tri[1], tri[2], rl.RED)
  
      }
    }

    rl.DrawFPS(0,0)
  }
}