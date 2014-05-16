
attribute vec4 position;

attribute vec2 texPosIn;
varying vec2 texPosOut;

void main() {
    gl_Position = position;
    texPosOut = texPosIn;
}