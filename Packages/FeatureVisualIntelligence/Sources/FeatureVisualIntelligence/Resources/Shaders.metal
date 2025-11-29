#include <metal_stdlib>
using namespace metal;

// Distorts the coordinate space based on heat (strength) and time
[[ stitchable ]] float2 thermalMirage(float2 position, float strength, float time) {
    if (strength < 10.0) { return position; } // No effect if cool
    
    // Create a heat wave effect
    // vertical wave offset based on x position and time
    float wave = sin(position.y * 0.05 + time * 5.0) * (strength * 0.1);
    
    // Optional: Horizontal jitter
    float jitter = cos(position.x * 0.1 + time * 8.0) * (strength * 0.05);
    
    return float2(position.x + wave, position.y + jitter);
}
