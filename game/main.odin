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
  START :: physics.Vec3{-8, 10, -8}
  rl.InitWindow(800, 800, "Zelda Engine")
  rl.SetTargetFPS(60)
  camera := Camera{
    cam = {
      target = {0, 0, 0},
      position = START,
      up = {0, 1, 0},
      fovy = 90,
    },
    distance = 10,
  }

  player := physics.Entity{
    position = START,
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

    // player.position += player.velocity
    // player.velocity += {0,-0.05,0}
    // col := physics.collide_with_mesh(player.radius, player.position, player.velocity, model.meshes[0])

    physics.collide_and_slide(&player, model.meshes[0])

    // if col.kind != .None {
    //   player.position = 0.99999 * col.t * player.velocity
    //   normal := glm.normalize(col.intersection - player.position)
    //   fmt.println(normal, glm.length(normal))
    //   player.velocity = glm.reflect(player.velocity, normal) * 0.9
    // }


    if rl.IsKeyPressed(.R) {
      player.velocity = {}
      player.position = START
    }


    drawing: {
      rl.BeginDrawing()
      defer rl.EndDrawing()

      rl.ClearBackground(rl.BLACK)
      mode3d: {
        rl.BeginMode3D(camera.cam)
        defer rl.EndMode3D()

  
        rl.DrawSphere(player.position, player.radius, rl.GREEN)
        // rl.DrawSphereWires(player.position, player.radius, 5, 10, rl.BLUE)
        // wierd edges
        rl.DrawSphere({-3.1087608, 17.253014, -51.491505}, .5, rl.RED)
        rl.DrawSphere({5.6071806, 1, -8}, .5, rl.RED)
        rl.DrawSphere({28.015406, 17.253014, -52.889545}, .5, rl.RED)
        rl.DrawSphere({50, 17.253014, -7.0918159}, .5, rl.RED)

        rl.DrawSphere({28.10936, 14, -32}, .5, rl.RED)
        rl.DrawSphere({27, 8.2107038, 3.8104789}, .5, rl.RED)
        rl.DrawLine3D(player.position, player.position + 20 * player.velocity, rl.RED)

        shader_mode: {
          rl.BeginShaderMode(shader)
          defer rl.EndShaderMode()


          rl.DrawModel(model, {}, 1, rl.WHITE)
        }
        rl.DrawModelWires(model, {}, 1, rl.BLUE)
        // rl.DrawTriangle3D(tri[0], tri[1], tri[2], rl.RED)

  
      }
    }

    rl.DrawFPS(0,0)
  }
}

update_camera :: proc(player: ^physics.Entity, cam: ^Camera) {
  // dir: physics.Vec3
  // if rl.IsKeyDown(.W) do dir.z -= 1
  // if rl.IsKeyDown(.S) do dir.z += 1
  // if rl.IsKeyDown(.D) do dir.x -= 1
  // if rl.IsKeyDown(.A) do dir.x += 1

  // SPEED :: 0.05


  // player.velocity.x = SPEED * dir.x
  // player.velocity.z = SPEED * dir.z


  cam.cam.target = player.position
  cam.cam.position = glm.lerp(cam.cam.position, player.position + {0,10,6}, 0.025) 
  // cam.cam.position = A*b
} 