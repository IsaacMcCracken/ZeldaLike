package game

// Vendor Packages
import rl "vendor:raylib"
// Core Packages
// Game Packages
import "entity"



main :: proc () {
  rl.InitWindow(800, 800, "Zelda Engine")
  camera := rl.Camera{
    target = {0, 0, 0},
    position = {0, 3, 4},
    up = {0, 1, 0},
    fovy = 70,

  }

  player := entity.Entity{
    position = {0, 3, 0},
    flags = {.Physics, .Controllable}
  }
  rl.SetTargetFPS(60)

  manager := entity.Manager{}

  entity.add_literal(&manager, &player)


  for !rl.WindowShouldClose() {
    //update
    // rl.UpdateCamera(&camera, .ORBITAL)
    // entity.update_physics(&player)
    entity.update(&manager)

    if rl.IsKeyDown(.R) do player.position = {0, 3, 0}


    rl.BeginDrawing()
    defer rl.EndDrawing()
    rl.ClearBackground(rl.BLACK)

    rl.DrawRectangle(29, 20, 100, 100, rl.BLUE)

    mode3d: {
      rl.BeginMode3D(camera)
      defer rl.EndMode3D()

      rl.DrawPlane({0,0,0}, {10,10}, rl.RAYWHITE)
      rl.DrawSphere(player.position, 0.5, rl.DARKGREEN)
    }

    rl.DrawFPS(0,0)
  }
}