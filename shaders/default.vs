#version 330

in vec3 vertexPosition;     // Vertex input attribute: position
in vec2 vertexTexCoord;     // Vertex input attribute: texture coordinate
in vec4 vertexColor;        // Vertex input attribute: color

uniform mat4 mvp;           // Model-View-Projection matrix

out vec2 fragTexCoord;      // To-fragment attribute: texture coordinate
out vec4 fragColor;         // To-fragment attribute: color


void main() {
  fragTexCoord = vertexTexCoord
  fragColor = vertexColor
  gl_Position = mvp*vec4(vertexPosition, 1.0);
}