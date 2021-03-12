#version 300 es

// Fragment shader
precision highp float;

#define PI 3.14159265359
#define PI2 6.28318530718

in vec2 UV;
uniform float time;
uniform float ratio;
out vec4 out_color;


vec4 bridge(vec2 pos);

float leaf(vec2 pos){
    if(pos.y > 1.0 || pos.y < 0.0){
        return 0.0;
    }
    pos *= 2.0;
    pos.y *= -0.7;
    float func = 0.0;
    pos.x *= 1.0;
    func = 0.0 - 6.0 * pow(pos.x, 2.0) + 0.3;
    func += 0.07 * cos(pos.x * 6.0);
    func += 0.02 * cos(pos.x * 170.0);

    if(-pos.y < func){
        if(cos((pos.y - func) * 80.0) < 0.8){
            return 0.7;
        }
        return 0.3;
    }

    return 0.0;
}

vec4 leaves(vec2 pos){
    vec2 tpos;
    vec4 col = vec4(0.0);

    vec2 top = vec2(-0.225, 0.22);
    float dtop = length((top - pos) * vec2(1.0, 1.4));
       vec2 v = top - pos;
    float treefac = 0.0;

    if(dtop < 0.6){
        float angle = atan(v.y, v.x);
        tpos = vec2(cos(angle * 5.0 + 0.02 * cos(time * PI2)), 10.0 * dtop);

        treefac += leaf(0.1 * tpos);

        if(treefac > 0.0){
            col.rgb = treefac * vec3(0.0, 0.1, 0.2);
        }
    }

    col.a = treefac;

    return col;
}

vec4 boat(vec2 pos){
    vec4 col = vec4(0.0);

    if(pos.y < 0.1 && pos.y > -0.1){
        if(pos.x < 0.3 + 0.5 * pos.y && pos.x > -0.3 - 0.5 * pos.y){
            col.rgb += 0.2;
        }
    }

    float polex = -0.03;

    if(distance(pos.x, polex) < 0.014 && pos.y > 0.1 && pos.y < 0.48){
        col.rgb += 0.1;
    }

    if(pos.x > 0.05 + polex && pos.x < 0.4 - 0.7 * pos.y + polex && pos.y > 0.14 && pos.y < 0.48){
        col.rgb += 0.2;
    }

    return col;
}


void main(void){
    float x = UV.x * ratio - 0.5 * ratio;
    float y = UV.y - 0.5;
    vec2 pos = vec2(x, y);

    vec4 col = vec4(0.0);

    vec2 tpos;

    float water_offset = 0.003 * cos(pos.y * (3.0 * (pow(11.0 - 40.0 * pos.y,2.0))) + time * PI2);

    if(y < -0.3){
        // GROUND
        col.rgb = vec3(0.1,0.0,0.2);
    } else if (y < -0.2) {
        // WATER
        col.rgb = vec3(0.2,0.24,0.9);

        tpos = pos;
        tpos.x += water_offset;

        if(distance(vec2(0.0, -0.2), tpos) < 0.08){
            // SUN REFLECTION
            col.rgb = vec3(1.0,0.1,0.3);
        }
    } else {
        // SKY
        col.rgb = vec3(0.6 * (-1.4 * pos.y + 1.2),0.24,0.7);

        if(distance(vec2(0.0, -0.2), pos) < 0.08){
            // SUN
            col.rgb = vec3(1.0,0.5,0.3);
        }
    }

    col += bridge(pos + vec2(0.0, 0.2));
    if(pos.y > -0.3){
        col += bridge(pos * vec2(1.0, -1.0) - vec2(water_offset, 0.2));
    }

    // TREE
    float trunk = -0.6 + 0.3 * pow(3.0, pos.y + 0.004 * cos(pos.y * 6.0 + time * PI2));
    float trunksize = 0.002 * cos(300.0 * pos.y) + 0.01;
    vec2 lpos = pos; // leaves pos [(l)pos]
    lpos.y += 1.5 * pow((pos.x + 0.29), 2.0);
    lpos += 0.001 * cos(x * 20.0 + time * PI2);
    vec4 leaves = leaves(lpos);
    col = leaves * leaves.a + (1.0 - leaves.a) * col;

    if(distance(pos.x, trunk) < trunksize && pos.y < 0.2 && leaves.a < 0.5){
        col.rgb = vec3(0.14,0.1,0.2);
    }



    col += 1.0 * boat(pos * 17.0 + vec2(-5.4, 3.3 + 0.01 * cos(time * PI2)));
    col += 0.4 * boat((pos * 17.0 + vec2(-5.4, 3.5 - 0.01 * cos(time * PI2))) * vec2(1.0, -1.0));



    col.a = 1.0;

    out_color = col;
}


float tri(float x){
    if(mod(x,2.0) < 1.0){
        return mod(x,1.0);
    } else {
        return 1.0 - mod(x - 1.0,1.0);
    }
}

vec4 bridge(vec2 pos){
    vec4 col = vec4(0.0);

    float floor = 0.01 * cos(10.0 * pos.x) + 0.01;

    floor += 0.006 * cos(pos.x * 10.4);
    floor += 0.13 * cos(pos.x * 2.0);

    if(distance(floor, pos.y) < 0.03){
      if(distance(floor, pos.y) < 0.003){
          col.rgb = vec3(0.4);
          col.a = 1.0;
      }

      // Vehicles (front lane)
      if(pos.y > floor + 0.003 && pos.y < floor + 0.014){
          float vehicle = cos(pos.x * 100.0 + time * PI2);
          vehicle = vehicle < 0.0? 0.0: 1.0;
          if(vehicle > 0.0){
              col.rgb = vec3(0.1);
              col.a = 1.0;
          }
      }

      // Vehicles (back lane)
      if(pos.y > floor + 0.003 && pos.y < floor + 0.01){
          float vehicle = cos(pos.x * 100.0 - time * PI2);
          vehicle = vehicle < 0.0? 0.0: 1.0;
          if(vehicle > 0.0){
              col.rgb = vec3(0.1);
              col.a = 1.0;
          }
      }
    }

    float supportheight = 0.1;

    float space = 2.0;

    if(pos.y < floor + supportheight && pos.y > 0.0){
        if(1.0 * cos(space * 10.0 * pos.x) + 1.0 < 0.003){
            col.rgb = vec3(0.2);
            col.a = 1.0;
        }
        float triheight = supportheight * tri(pos.x * space * PI);
        if(pos.y > floor && pos.y - floor < triheight){
            if(cos(700.0 * (pos.y - floor - triheight)) < -0.3){
                col.rgb = vec3(0.3);
                col.a = 1.0;
            }
        }
    }



    return col;
}
