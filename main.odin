package game

// Vendor Packages
import rl "vendor:raylib"
// Core Packages
import glm "core:math/linalg/glsl "
import "core:fmt"
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

  model := rl.LoadModel("assets/model/triangle.obj")
  tri := [3]physics.Vec3{{-5, 0, 5}, {5, 3, 0,}, {-5, 0, -5}}


  happened := false

  rl.SetTargetFPS(60)
  rl.HideCursor()
  for !rl.WindowShouldClose() {
    player.position += player.velocity
    

    

    if col, ok := physics.collision_sphere_triangle(&player, tri); ok {
      fmt.println(col)
      player.velocity = glm.reflect(player.velocity, col.normal)
      player.position = col.intersection + col.normal * player.radius
      happened = true
    } else {
      player.velocity.y -= 0.05 * rl.GetFrameTime()
    }
    

    rl.UpdateCamera(&camera, .THIRD_PERSON)


    if rl.IsKeyPressed(.R) {
      happened = false
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
      rl.DrawSphere({6.2943025, 3.3882906, 0.64715117}, 0.2, rl.PURPLE)

        rl.DrawTriangle3D(tri[0], tri[1], tri[2], rl.RED)

  
      }
    }

    rl.DrawFPS(0,0)
  }
}