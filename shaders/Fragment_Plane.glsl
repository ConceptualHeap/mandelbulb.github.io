precision mediump float;

#define _MaxDist 100.0
#define _MaxSteps 200.0
#define _Epsilon 0.001

float _Power = 8.0;

uniform float aspect;
uniform float xSize;
uniform float ySize;
uniform float uTime;

varying vec2 vUv;

float steps = 0.0;
float depth = 0.0;

float SDF(vec3 pos) {
    vec3 z = pos;
    float dr = 1.0;
    float r = 0.0;

    for(float i = 0.0; i < 20.0; i++) {
        r = length(z);
        steps = i;
        if(r > 4.0) break;

        // Convert to polar coordinates
        float theta = acos(z.z / r);
        float phi = atan(z.y / z.x);
        dr = pow(r, _Power-1.0) * _Power * dr + 1.0;

        // Scale and Rotate the Point
        float zr = pow(r, _Power);
        theta = theta * _Power;
        phi = phi * _Power;

        // Convert back into cartesian coordinates
        z = zr * vec3(sin(theta) * cos(phi), sin(phi) * sin(theta), cos(theta));
        z += pos;
    }

    return 0.5 * log(r) * r / dr;
}

float trace(vec3 rayOrigin, vec3 rayDir) {

    for(float i = 0.0; i < _MaxSteps; ++i) {
        float dist = SDF(rayOrigin + depth*rayDir);
        if(dist < _Epsilon) return depth;
        depth += dist;
        if(depth > _MaxDist) return _MaxDist;
    }
    
    return _MaxDist;
}

vec3 lerp(vec3 col1, vec3 col2, float value) {
  return (col1 * value) + (col2 * (1.0 - value));
}

void main() {

    vec2 fragCoords = vUv * vec2(xSize, ySize);

    vec2 coords = vUv;//fragCoords - vec2(xSize, ySize) / 2.0;
    coords -= 0.5;
    coords.x *= aspect;
    coords.x = abs(coords.x);
    coords *= xSize;

    //vec3 rayOrigin = vec3(0.0, 0.5 * sin(uTime), 2.0 + sin(uTime / 3.0)); //vec3(0.0, 1.0, 0.0);
    vec3 rayOrigin = vec3(0.0, 0.0, 5);
    vec3 rayDir = normalize(vec3(coords + vec2(00.0, 0.0), -ySize / tan(radians(30.0) / 2.0)));

    _Power = (sin(uTime) * 4.0) + 8.0;

    float dist = trace(rayOrigin, rayDir);


    //vec3 col = lerp(vec3(0.004, 0.125, 0.188), vec3(0.855, 0.992, 0.729), dist);

    if(dist < _MaxDist) {
        //gl_FragColor = vec4(vec3(clamp(steps / 20.0, 0.0, 1.0)), 1.0);
        dist = clamp(steps / 20.0, 0.0, 1.0);
        depth = 1.0 - (depth / 10.0);
        vec3 col = lerp(vec3(0.004, 0.125, 0.188), vec3(0.855, 0.992, 0.729), dist);
        //vec3 col = lerp(vec3(0.176, 0.243, 0.251), vec3(0.894, 0.949, 0.906), dist);
        gl_FragColor = vec4(col, 1.0);
        //gl_FragColor = vec4(vec3(1.0 - (depth / 10.0)), 1.0);
        return ;
    }

    //gl_FragColor = vec4(coords, 0.0, 1.0);
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
    //gl_FragColor = vec4(1.0, 0.5, 0.25, 1.0);
}