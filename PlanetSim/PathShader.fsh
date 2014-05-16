
varying vec2 texPosOut;
uniform sampler2D Texture;

void main() {
    vec4 orig = texture2D(Texture, texPosOut);
    gl_FragColor = orig;
}