#version 450

layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 outColor;

layout(set = 0, binding = 0) uniform sampler2D source;
layout(set = 0, binding = 1) uniform TintParams {
  vec4 tintColor;
  float phase;
} params;

void main() {
  vec4 color = texture(source, v_uv);
  float wave = 0.5 + 0.5 * sin(params.phase + v_uv.x * 6.2831853);
  float amount = params.tintColor.a * wave;
  vec3 tinted = mix(color.rgb, params.tintColor.rgb, amount);
  outColor = vec4(tinted, color.a);
}
