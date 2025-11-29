#include <metal_stdlib>
using namespace metal;

// Simple Hash
float hash(float2 p) {
    float3 p3  = fract(float3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

// Gradient Noise
float noise(float2 x) {
    float2 i = floor(x);
    float2 f = fract(x);
    float a = hash(i);
    float b = hash(i + float2(1.0, 0.0));
    float c = hash(i + float2(0.0, 1.0));
    float d = hash(i + float2(1.0, 1.0));
    float2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

// Fractal Brownian Motion (Octaves)
float fbm(float2 x, int octaves) {
    float v = 0.0;
    float a = 0.5;
    float2 shift = float2(100.0);
    // Rotate to reduce axial bias
    float2x2 rot = float2x2(cos(0.5), sin(0.5), -sin(0.5), cos(0.50));
    for (int i = 0; i < octaves; ++i) {
        v += a * noise(x);
        x = rot * x * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

// Shader function callable from SwiftUI
[[ stitchable ]] half4 turbulence(float2 position, half4 color, float2 size, float seed) {
    float2 uv = position / size;
    uv.x *= size.x / size.y;
    float2 noisePos = uv * 10.0 + float2(seed * 100.0);
    float n = fbm(noisePos, 3);
    float grain = n;
    return half4(grain, grain, grain, 0.15);
}
