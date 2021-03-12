#version 300 es
precision highp float;

in vec2 UV;
out vec4 out_color;
uniform float ratio, time;
uniform sampler2D texture0, texture1;

void main(void) {
  vec2 p   = vec2(UV.x * ratio, UV.y) - vec2(0.5*ratio, 0.5);
  int  i   = int(p.x * 2e3 + 2e4 + time * 100.0);
  int  j   = int(p.y * 2e3 + 2e3 + time * 200.0);
  int  z   = 1;
  out_color = vec4(1.0);

  for (int k = 2; k > 0; k--) {
    z += ((i ^ j) % (i / j) < 3) ? 1: 0;
    float f = z > 1 ? 4.0/(1.0+float(k*2)): 0.0;
    i /= 20;
    j /= 20;
  }

  vec4 t0 = texture(texture0, UV * vec2(1.0, -1.0) + vec2(0.0, 1.0));
  vec4 t1 = texture(texture1, UV * vec2(1.0, -1.0) + vec2(0.0, 1.0));

  if (z < 3) {
    out_color = t0 * t0.a;
  } else {
    out_color = t1 * t1.a;
  }

  out_color.rgb = 1.0-floor(cos(vec3(length(out_color)) * 1.0) * 6.0 + 0.1 * cos(floor(p.x * 300.0 + time * 6.2832))) * 0.4;

  out_color.a = 1.0;
}
