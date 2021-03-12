#version 300 es
precision highp float;

in vec2 UV;
out vec4 out_color;
uniform float ratio, time;
uniform sampler2D texture0;
uniform sampler2D texture1;

uniform float fracture_scale;        // custom_uniform {"name" : "fracture_scale", "humanName": "Fracture Scale", "defaultValue": 5, "min": 0, "max": 30}

#define angle(p) atan(p.y, p.x)

float mdist(vec2 p1, vec2 p2){
    return max(abs(p1.x - p2.x), abs(p1.y - p2.y));
}

void main(void){
    vec2 pts[9];

    // Ideally, this should be random
    pts[0] = vec2(0.84,0.53);
    pts[1] = vec2(-0.6555,-0.33);
    pts[2] = vec2(-0.9543,-0.85);
    pts[3] = vec2(0.64656,-0.6);
    pts[4] = vec2(-0.46563,-0.8);
    pts[5] = vec2(1.0646,0.3157);
    pts[6] = vec2(0.74,0.9345);
    pts[7] = vec2(-0.68,-0.8);
    pts[8] = vec2(0.54,0.31);

    vec2 p = vec2(UV.x * ratio, UV.y) - vec2(0.5);

    p *= fracture_scale;

    vec4 col = vec4(0.0);

    int best = 0;
    int second_best = -1;
    float distances[8];

    for(int i = 0; i < 8; i++){
        float md = mdist(pts[i], p);
        float d = distance(pts[i], p);

        float f = 0.6;

        d = cos((f * d + (1.0 - f) * md) * (10.1 + cos(time*6.2832) * 0.01) + 4.2);

        distances[i] = d;

        if(distances[i] < distances[best]){
            second_best = best;
            best = i;
        }
    }

    float d = distances[best];
    float v = 0.0;

    float s = 0.0;

    // Color intersections
    if ( second_best != -1 ) {
        s = abs(distances[best] - distances[second_best]);
    }

    float limit = 0.1 + 0.1 * cos(time * 6.2832);

    if(s < limit){
        v += 1.0;
    }

    vec4 t0 = texture(texture0,  UV * vec2(1.0, -1.0) + vec2(0.0, 1.0));
    t0 *= t0.a;
    vec4 t1 = texture(texture1,  UV * vec2(1.0, -1.0) + vec2(0.0, 1.0));

    float m = 0.0;

    if(s < limit){
      m = v;
    }

    col = mix(t1,t0,m);

    col.a = 1.0;

    out_color = col;
}
