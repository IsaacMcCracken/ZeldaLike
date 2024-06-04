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
    position = {0, 6, 8},
    up = {0, 1, 0},
    fovy = 90,

  }

  player := entity.Entity{
    position = {0, 3, 0},
    ellipsoid = {1, 1, 1},
    flags = {.Physics, .Controllable}
  }
  rl.SetTargetFPS(60)

  manager := entity.Manager{}

  entity.add_literal(&manager, &player)

  

  triangle := [3]rl.Vector3{{-5, -1, -5}, {-5, -1, 5}, {5, 3, 0}}
  plane := entity.plane_from_triangle(triangle)

  for !rl.WindowShouldClose() {
    //update
    rl.UpdateCamera(&camera, .ORBITAL)
    // entity.update_physics(&player)
    entity.update(&manager, rl.GetFrameTime())

    if rl.IsKeyDown(.R) {
      player.position = {0, 5, 0}
      player.velocity = {}
    } 


    rl.BeginDrawing()
    defer rl.EndDrawing()
    rl.ClearBackground(rl.BLACK)

    rl.DrawRectangle(29, 20, 100, 100, rl.BLUE)

    mode3d: {
      rl.BeginMode3D(camera)
      defer rl.EndMode3D()

      // rl.DrawPlane({0,0,0}, {10,10}, rl.RAYWHITE)
      rl.DrawTriangle3D({-5, -1, -5}, {-5, -1, 5}, {5, 3, 0}, rl.SKYBLUE)
      rl.DrawLine3D({}, 3*plane.normal, rl.PURPLE)
      
      
      
      data, ok := entity.sweep_ellipsoid_triangle_collision(player.physics, triangle, rl.GetFrameTime())

      color := rl.GREEN
      if ok {
        player.position = data.intersection
        color = rl.RED
      }

      rl.DrawSphere(player.position, 1, color)
    }

    rl.DrawFPS(0,0)
  }
}