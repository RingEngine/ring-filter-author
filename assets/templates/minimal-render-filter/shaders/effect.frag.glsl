#version 450

layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 outColor;

layout(set = 0, binding = 0) uniform sampler2D source;
layout(set = 0, binding = 1) uniform EffectParams {
  float strength;
} params;

void main() {
  vec4 color = texture(source, v_uv);
  float luma = dot(color.rgb, vec3(0.2126, 0.7152, 0.0722));
  vec3 grayscale = vec3(luma);
  outColor = vec4(mix(color.rgb, grayscale, params.strength), color.a);
}
