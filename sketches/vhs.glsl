#version 300 es
precision highp float;

in vec2 UV;
uniform vec2 mouse;
out vec4 out_color;
uniform float ratio, time;

uniform sampler2D texture0;
uniform sampler2D texture1;

uniform float vignette;        // custom_uniform {"name" : "vignette", "humanName": "Vignette"}
uniform float distort;         // custom_uniform {"name" : "distort", "humanName": "Distort"}
uniform float noise;           // custom_uniform {"name" : "noise", "humanName": "Noise"}
uniform float noise_frequency; // custom_uniform {"name" : "noise_frequency", "humanName": "Noise Frequency"}
uniform float fade;            // custom_uniform {"name" : "fade", "humanName": "Fade", "defaultValue": 0.1}

#define PI 3.1416
#define PI2 (2.0 * PI)

vec2 UVGlitcher(vec2 UV, float offset) {
  float t = time * 6.0;
  float vhs = (0.2 + 0.1 * cos(t)) *
    cos(UV.y * 10.0 + 0.3 * tan(UV.y * 10.0 + t + offset) + 1.0 * t);

  vhs = clamp(vhs, 0.0, 1.0);

  UV.x += 0.4 * distort * vhs;
  UV.y += 0.4 * distort * vhs + 0.005 * distort * cos(t + UV.x * 10.0);

  return UV;
}

void main(void){
  float x = UV.x * ratio;
  float y = UV.y;

  // Position of current point
  vec2 p = vec2(x, y) - vec2(0.5 * ratio, 0.5);

  vec4 col = vec4(0.0);

  vec4 fg = texture(texture0,  vec2(1.0, -1.0) + vec2(0.0, 1.0));

  // fg is for foreground, bg for background
  vec2 bgUVr = UVGlitcher(UV, 0.0);
  vec2 bgUVg = UVGlitcher(UV, 0.1);
  vec2 bgUVb = UVGlitcher(UV, 0.2);

  vec4 bg = vec4(0.0);

  bg.r += texture(texture1, bgUVr * vec2(1.0, -1.0) + vec2(0.0, 1.0)).r;
  bg.g += texture(texture1, bgUVg * vec2(1.0, -1.0) + vec2(0.0, 1.0)).g;
  bg.b += texture(texture1, bgUVb * vec2(1.0, -1.0) + vec2(0.0, 1.0)).b;

  float w = noise_frequency;
  bg.rgb += 0.1 * noise * clamp(pow(cos(tan(UV.y * 800.0 * w + UV.x * 500.0 * w)+ UV.x * 200.0 * w) *
                                    cos(time * PI2 * w + UV.y * 300.0 * w + UV.x * 28.0 * w) +
                                    cos(UV.y * 160.0 * w + 30.0 * time * PI2) *
                                    cos(UV.x * 56.0 * w - 10.0 * time * PI2), 2.0), 0.0, 1.0);

  // In this case, the image is not premultiplied
  col = fg * fg.a * (cos(p.x * 10.0) * 0.1 + 1.0);

  col = mix(bg, fg, fg.a);

  col -= 5.0 * vignette * pow(length(p), 1.5);

  col *= 1.0 - fade;
  col += fade;

  col.a = 1.0;

  out_color = col;
}
