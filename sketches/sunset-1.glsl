#version 300 es
precision highp float;

in vec2 UV;
uniform vec2 mouse;
out vec4 out_color;

void main(void) {
  vec2 p = vec2(UV.x, UV.y) - vec2(0.5, 0.5);
  out_color = vec4(0.0);

  if (p.y < 0.0)
    p.x += 0.1 * p.y * cos(p.y * 100.0);

  float l = length(p);
  float a = atan(p.y,p.x);
  float s = 1.0 - pow(clamp((l-0.03), 0.0, 1.0), 0.9);

  s += 1.0-pow(clamp((l - 0.03) / 0.1, 0.0, 1.0), 0.1);
  s += 0.01 * cos(a * 20.0 + l);
  out_color.r += 0.9 * s;
  out_color.g += 0.3 * s;
  out_color.b += 0.1 * s;

  if (p.y < 0.0)
    out_color -= vec4(0.2, -0.9 * p.y, 0.4 * p.y, 0.0);

  out_color.a = 1.0;
}
