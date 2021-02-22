#version 300 es
precision highp float;

in vec2 UV;
uniform vec2 mouse;
out vec4 out_color;
uniform float ratio, time;

uniform sampler2D texture0;
uniform sampler2D texture1;

void main(void){
    float x = UV.x * ratio;
    float y = UV.y;

    // Position of current point
    vec2 p = vec2(x, y) - vec2(0.5 * ratio, 0.5);

    vec4 col = vec4(0.0);

    // fg is for foreground, bg for background
    vec4 fg = texture(texture0,  UV * vec2(1.0, -1.0) + vec2(0.0, 1.0));
    vec4 bg = texture(texture1,  UV * vec2(1.0, -1.0) + vec2(0.0, 1.0));

    // In this case, the image is not premultiplied
    //col += fg * fg.a * (cos(p.x * 10.0) * 0.1 + 1.0);
    //col += bg * bg.a * (1.0 - fg.a);
    col = bg;
    col.a = 1.0;

    out_color = col;
}
