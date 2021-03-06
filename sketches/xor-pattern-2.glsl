#version 300 es
precision highp float;

in vec2 UV;
out vec4 out_color;
uniform float ratio;
uniform sampler2D texture0;

void main(void) {
  vec2 p   = vec2(UV.x * ratio, UV.y) - vec2(0.5);
  int  i   = int(p.x * 4e4 + 2.7e5);
  int  j   = int(-p.y * 4e4 + 2.3e4);
  int  z   = 1;
  bool b   = false;
  out_color = vec4(1.0);

  for (int k = 3; k > 0; k--) {
    z += ((i ^ j) % (i / j) < 3) ? 1: 0;
    b = z > 1;
    i /= 10;
    j /= 10;
  }

  out_color.rgb -= (b? vec3(0.0): vec3(1.0,0.6,0.4));
  out_color.a = 1.0;
}
