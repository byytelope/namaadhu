#include <metal_stdlib>
using namespace metal;

static float cloudAlpha(texture2d<half> cloud, float2 point, float4 rect) {
    float2 uv = (point - rect.xy) / rect.zw;
    if (any(uv < 0.0) || any(uv > 1.0)) return 0.0;
    constexpr sampler linearSampler(coord::normalized, address::clamp_to_zero, filter::linear);
    return float(cloud.sample(linearSampler, uv).a);
}

[[ stitchable ]] half4 dhuhrCloudOcclusion(
    float2 position, half4 color, texture2d<half> cloud,
    float4 rect, float2 sun, float density, float isFlare
) {
    if (color.a < 0.0001h) return color;
    float alpha;
    if (isFlare > 0.5) {
        // Average the finite sun disc so a fine texture edge cannot flicker the ghosts.
        alpha = cloudAlpha(cloud, sun, rect) * 0.4;
        alpha += cloudAlpha(cloud, sun + float2(5, 0), rect) * 0.15;
        alpha += cloudAlpha(cloud, sun - float2(5, 0), rect) * 0.15;
        alpha += cloudAlpha(cloud, sun + float2(0, 5), rect) * 0.15;
        alpha += cloudAlpha(cloud, sun - float2(0, 5), rect) * 0.15;
    } else {
        alpha = cloudAlpha(cloud, position, rect);
    }
    // Keep these light clouds translucent to the sun; flares remain more
    // sensitive to coverage without disappearing as quickly.
    float transmission = exp(-alpha * density * (isFlare > 0.5 ? 1.6 : 1.0));
    return color * half(transmission);
}

[[ stitchable ]] half4 dhuhrCloudLighting(
    float2 position, half4 color, float2 sun, float density
) {
    float alpha = float(color.a);
    if (alpha < 0.0001) return half4(0);
    float3 base = float3(color.rgb) / alpha;
    float distanceToSun = length(position - sun);
    float illumination = exp(-distanceToSun * distanceToSun / (2.0 * 62.0 * 62.0));
    // Most light passes through the wispy margins, with a subdued grey body.
    float rim = 4.0 * alpha * (1.0 - alpha);
    float3 lit = base * float3(0.87, 0.93, 1.0)
        + float3(0.95, 0.81, 0.57) * illumination * (0.16 + 0.65 * rim);
    float visibleAlpha = alpha * density * 0.42;
    return half4(half3(lit * visibleAlpha), half(visibleAlpha));
}
