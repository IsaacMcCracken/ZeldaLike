package game

// Vendor Packages
import rl "vendor:raylib"
// Core Packages
import glm "core:math/linalg/glsl "
import "core:fmt"
// Game Packages
import "../entity"
import "../physics"




main :: proc () {
  rl.InitWindow(800, 800, "Zelda Engine")
  rl.SetTargetFPS(60)
  camera := Camera{
    cam = {
      target = {0, 0, 0},
      position = {0, 6, 8},
      up = {0, 1, 0},
      fovy = 90,
    },
    distance = 10,
  }

  player := physics.Entity{
    position = {0, 10, 0},
    radius = 1,
  }

  texture := rl.LoadTexture("assets/model/texture.png")
  model := rl.LoadModel("assets/model/demo.obj")
  
  rl.SetMaterialTexture(&model.materials[0], .ALBEDO, texture)
  fmt.println(model.materials[0])
  if model.meshes[0].normals != nil do fmt.println("YAYAYYAYAYAYYAY LOOK THERE ARE NORMALS")
  else do fmt.println("HEYOBOOO")
    
  shader := rl.LoadShader("shader/default.vs", "shaders/default.fs") 
  
  happened := false

  rl.SetTargetFPS(60)
  rl.HideCursor()
  for !rl.WindowShouldClose() {
    
    update_camera(&player, &camera)

    player.velocity += {0,-0.05,0}
    physics.collide_and_slide(&player, model.meshes[0])


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
        rl.BeginMode3D(camera.cam)
        defer rl.EndMode3D()
  
        rl.DrawSphere(player.position, player.radius, rl.GREEN)

        shader_mode: {
          rl.BeginShaderMode(shader)
          defer rl.EndShaderMode()


          rl.DrawModel(model, {}, 1, rl.WHITE)
        }
        // rl.DrawTriangle3D(tri[0], tri[1], tri[2], rl.RED)

  
      }
    }

    rl.DrawFPS(0,0)
  }
}

update_camera :: proc(player: ^physics.Entity, cam: ^Camera) {
  dir: physics.Vec3
  if rl.IsKeyDown(.W) do dir.z -= 1
  if rl.IsKeyDown(.S) do dir.z += 1
  if rl.IsKeyDown(.D) do dir.x -= 1
  if rl.IsKeyDown(.A) do dir.x += 1

  SPEED :: 0.05


  player.velocity.x = SPEED * dir.x
  player.velocity.z = SPEED * dir.z


  cam.cam.target = player.position
  cam.cam.position = player.position + {0,10,6}
  // cam.cam.position = A*b
} 