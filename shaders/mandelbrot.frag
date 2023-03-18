#include <flutter/runtime_effect.glsl>
uniform vec2 uSize;
uniform float scale;
uniform vec2 offset;
out vec4 fragColor;

int mandel(float cr, float ci) {
    float zr = 0.;
    float zi = 0.;
    float zrsqr = 0.;
    float zisqr = 0.;

    for(int i = 0; i < 1000; i++) {
        zi = 2.0 * (zr * zi) + ci;
        zr = zrsqr - zisqr + cr;
        zrsqr = zr * zr;
        zisqr = zi * zi;
        if(zrsqr + zisqr > 4.0) {
            return i;
        }
    }

    return -1;
}

vec2 transform(vec2 point) {
    mat2 scaleM;
    scaleM[0] = vec2(2.5, 0.0) * 2.0;
    scaleM[1] = vec2(0.0, 2.0) * 2.0;
    vec2 shift = vec2(-3.0, -2.0);
    return scaleM * point + shift;
}

void main() {
    vec2 st = FlutterFragCoord().xy / uSize;
    mat2 scaleM;
    scaleM[0] = vec2(scale, 0.0);
    scaleM[1] = vec2(0.0, scale);
    vec2 position = vec2(
        st.x - offset.x,
        st.y - offset.y
    );
//    vec2 scaled = scaleM * position;
    vec2 scaled = transform(st);
    int steps = mandel(scaled.x - offset.x, scaled.y - offset.y);
//    int steps = mandel((st.x - offset.x) * scale / 2.0, (st.y - offset.y) * scale / 2.0);
    float blue = 0.5 - 1.0 / (scale * float(steps));
    float red = 0.7 - 1.0 / (scale * float(steps));
    float green = 0.6 - 1.0 / (scale * float(steps));
    vec3 color = steps == -1 ? vec3(0.5, 0.7, 0.6) : vec3(red, green, blue);
    fragColor = vec4(color, 1.0);
}
