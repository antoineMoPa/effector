#version 300 es
precision highp float;

in vec2 UV;
uniform vec2 mouse;
out vec4 out_color;
uniform float ratio, time;

#define time mod(time * 0.1, 1.0)

uniform float mix_tex; // custom_uniform {"name" : "mix_tex", "humanName": "Mix"}
uniform float add_tex; // custom_uniform {"name" : "add_tex", "humanName": "Add"}
uniform float grid_density; // custom_uniform {"name" : "grid_density", "humanName": "Grid Density", "min": 0, "max": 30}

uniform sampler2D texture0;
uniform sampler2D texture1;

void main(void){
    float x = UV.x * ratio;
    float y = UV.y;


    // Position of current point
    vec2 p = vec2(x, y) - vec2(0.5 * ratio, 0.5);

    // Some fake camera position
    vec3 camera = vec3(p.x * 1.0, -10.0, p.y * 1.0);
    float h = 0.0;
    p.y *= 2.0;

    vec2 p_backup = p;

    h += 1.1 * cos(p.x * 172.2 - 10.0 * sin(p.y * 20.0) + time * 6.2832);
    h += 1.1 * cos(p.y * 272.2 + time * 6.2832);
    h += 0.1 * cos(p.x * 311.0 + time * 6.2832);
    h += 0.1 * cos(p.y * 361.0 + time * 6.2832);
    h += 0.2 * cos(p.x * 3.0 + time * 6.2832);
    h += 0.2 * cos(p.y * 5.0 + time * 6.2832);

    // Approximate derivative of H with respect to x and y
    float dhx = 0.8 * -sin(p.x * 172.2 - 10.0 * sin(p.y * 20.0) + time * 6.2832);
    float dhy = 0.8 * -sin(p.y * 272.2 + time * 6.2832);
    dhx += 0.1 * -sin(p.x * 311.0 + time * 6.2832);
    dhy += 0.1 * -sin(p.y * 361.0 + time * 6.2832);
    dhx += 0.2 * -sin(p.x * 3.0 + time * 6.2832);
    dhy += 0.2 * -sin(p.y * 5.0 + time * 6.2832);

    p.y += 0.004 * h;

    vec4 col = vec4(0.0);

    vec2 center = vec2(0.0);

    // Distance of current point to center of circle
    float d = distance(p, center);

    vec3 lamp = vec3(2.0, 10.0, 2.0);

    float a = atan(p.y, p.x);

    if(p.y < 0.0){
        col.rgba = vec4(0.3, 0.3, 0.5, 1.0);

        vec3 normal = normalize(vec3(-1.0,-1.0,dhx + dhy));
        vec3 refl = reflect(lamp - vec3(p,0.0), normal);

        // Pretty sure the spec and/or diffuse lighting is wrong here,
        // But I like the result
        float spec = pow(10.0,-3.0) * pow(dot(refl, camera - vec3(p,0.0)), 4.0);
        float diff = pow(10.0,-2.4) * pow(dot(normal, lamp), 2.0);
        col.rgb += 0.04 * clamp(spec, 0.0, 1.0);
        col.rgb += 0.04 * clamp(diff, 0.0, 1.0);
        col -= 0.6;
    }

    p = vec2(x, y) - vec2(0.5 * ratio, 0.5);

    if(p.y < 0.0){
        p.y *= -1.0 ;
    }

    col.r += 0.4;
    col.rg += 1.0 - 2.0 * p.y;
    col.b += 0.4;
    col.rgb *= 1.1 + clamp(1.0 - 0.1 * vec3(0.9, 0.5, 0.4) * pow(10.0 * length(p + vec2(0.0, -0.1 + time)), 10.0) , 0.0, 1.0) * clamp(pow(4.0 * cos(-p.y * 160.0 + time * 6.2832),4.0), 0.0, 1.0);
    col.b += 0.1;

    if(p_backup.y < 0.0){
        col *= 0.8;
    }

    col *= 1.0 - length(p);
    col.rgb *= 3.0 - 2.1 * pow(2.5 * length(p + vec2(0.0, time * 0.6)), 0.2);
    col.r *= 3.0 - 1.7 * pow(2.5 * length(p + vec2(0.0, time * 0.6)), 0.2);
    col *= 1.0 - pow(length(p), 2.0);
    col *= 1.0 - pow(length(p), 4.0);
    col *= 1.0 - pow(length(p), 8.0);
    col *= 1.0 - pow(length(p), 16.0);
    col *= 1.0 - pow(length(p), 32.0);

    if(p_backup.y < 0.0){
        col.r += 0.7 * clamp(cos(grid_density * p.x * pow(2.0 - p.y,2.0) * 10.0),0.4, 0.5) - 0.3;
        col.r += 0.7 * clamp(cos(pow(1.0 + p.y, 2.0) * 100.0 - time * 6.2832),0.4, 0.5) - 0.3;
    }

    col *= 1.0 + length(p) * 0.2 * pow(0.8 * cos(length(p) * 40.0 - time * 6.232) * time, 1.0);

    vec4 t0 = texture(texture0, UV * vec2(1.0, -1.0) + vec2(0.0, 1.0));
    t0 *= t0.a;
    col += t0 * add_tex;
    col = mix(col, t0, t0.a * mix_tex);

    col.a = 1.0;
    out_color = col;
}
