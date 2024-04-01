precision mediump float;

varying vec2 vUv;
varying vec3 vPosition;

uniform vec3 camPos;
uniform float uTime;
uniform float power;
uniform vec3 innerCol;
uniform vec3 outerCol;
uniform float detail;
uniform bool withMist;
uniform bool onlyMist;
uniform float mistFact;
uniform bool autoPower;


const float MAX_STEPS = 100.0;
const float MAX_DIST = 200.0;
float MIN_DIST;
float _Power;

float distOrigin = 0.0;
float steps;

float getDist(vec3 pos) {
    //float dist = length(pos) - 0.5; // sphere
    //dist = length(vec2(length(pos.xy) - 0.25, pos.z)) - 0.1;
    //return dist;

    if(autoPower)
        _Power = (cos(uTime) + 1.0) * 9.0 + 2.0;
    else
        _Power = power;

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

float march(vec3 rayOrigin, vec3 rayDir) {
    float distScene;
    MIN_DIST = 1.0 / (detail * 100.0);
    for (float i = 0.0; i < MAX_STEPS; i++) {
        vec3 pos = rayOrigin + distOrigin * rayDir;
        distScene = getDist(pos);
        distOrigin += distScene; 

        if(distScene < MIN_DIST || distOrigin > MAX_DIST) break;
    }
    return distOrigin;
}

vec3 getNormal(vec3 pos) { 
    vec2 epsilon = vec2(0.01, 0.0);
    vec3 norm = vec3(getDist(pos)) - vec3(
        getDist(pos - epsilon.xyy),
        getDist(pos - epsilon.yxy),
        getDist(pos - epsilon.yyx)
    );
    return normalize(norm);
}

vec3 lerp(vec3 col1, vec3 col2, float value) {
  return (col1 * value) + (col2 * (1.0 - value));
}

void main() {

    vec2 coords = vUv - 0.5;
    vec3 position = vPosition;
    vec3 rayOrigin = camPos;//vec3(0.0, 0.0, -3.0);
    vec3 rayDir = normalize(vec3(position - rayOrigin));//vec3(coords, 1.0);
    
    float d = march(rayOrigin, rayDir);

    vec3 col = vec3(0.0);
    vec3 pos;
    vec3 norm;

    if(d < MAX_DIST) {
        //pos = rayOrigin + rayDir * d;
        //norm = getNormal(pos);
        //col = norm;
        float mask = (clamp(steps / 20.0, 0.0, 1.0));
        //col = lerp(vec3(0.004, 0.125, 0.188), vec3(0.855, 0.992, 0.729), (mask));
        //col = lerp(vec3(0.176, 0.243, 0.251), vec3(0.894, 0.949, 0.906), (mask));
        col = lerp(innerCol, outerCol, (mask));
        //gl_FragColor = vec4(col, 1.0);
    }

    float mist = (1.0 - d / mistFact);

    if(!onlyMist) {
        if(withMist) gl_FragColor = vec4(col * mist, 1.0);
        else gl_FragColor = vec4(col, 1.0);
    }
    else
        gl_FragColor = vec4(vec3(mist), 1.0);
    //gl_FragColor = vec4(lerp(col, backgroundCol, normalize(steps)), 1.0);
    //gl_FragColor = vec4(vec3(1.0 - d / 6.0), 1.0);
}