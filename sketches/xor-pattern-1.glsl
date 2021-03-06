#version 300 es
precision highp float;

in vec2 UV;
out vec4 out_color;
uniform float ratio;
uniform sampler2D texture0;

void main(void) {
  vec2 p   = vec2(UV.x * ratio, UV.y) - vec2(0.5);
  int  i   = int(p.x * 2e3 + 2e4);
  int  j   = int(p.y * 2e3 + 2e3);
  int  z   = 1;
  out_color = vec4(1.0);

  for (int k = 2; k > 0; k--) {
    z += ((i ^ j) % (i / j) < 3) ? 1: 0;
    float f = z > 1 ? 4.0/(1.0+float(k*2)): 0.0;
    out_color.rgb -= f * vec3(1.0,0.6,0.4);
    i /= 20;
    j /= 20;
  }

  out_color.a = 1.0;
}
