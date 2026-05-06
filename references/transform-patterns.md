# Ring Transform Patterns

Use this reference when a filter involves output sizing, source placement, letterboxing, cropping, coordinate mapping, `mat4`, or shader varyings.

## Coordinate Spaces

Prefer coordinates that name a real domain:

- NDC (`a_position`): output geometry space in `[-1, 1]`, centered at `(0, 0)`, with `[-1, -1]` at the upper-left corner and `[1, 1]` at the lower-right corner. Use it for screen-layout geometry, center/radial effects, and angular tests.
- Source UV: input sampling space in `[0, 1]`, with `[0, 0]` at the upper-left corner and `[1, 1]` at the lower-right corner. Use it for texture sampling and inside-source tests.
- Pixel space: real width/height space. Use it when angle, radius, blur size, or distance must be aspect-correct.

Avoid "output UV" as a default intermediate. `a_position * 0.5 + 0.5` only means "NDC to normalized rectangle coordinates"; it is appropriate when the output rectangle maps directly to an output-sized texture or source. If a non-trivial Lua-computed transform already maps NDC to source UV, use that transform directly.

Name values by their domain and direction: `v_ndc`, `v_source_uv`, `ndcToSource`, `sourceToNdc`, `pixelToSource`.

## Active Output Layout

When `outputSizeMode` is `active`, treat output sizing and layout as reset-time work:

1. Read input dimensions in `onReset(ctx, outputRequest)`.
2. Decide output dimensions from the layout policy: fixed aspect ratio, fixed size, padded canvas, scaled canvas, content bounds, or another explicit policy.
3. Call `outputRequest:setSize(outputWidth, outputHeight)`.
4. Compute reset-invariant layout transforms such as `ndcToSource` or source placement matrices.

For a fixed-aspect canvas that contains the input:

```lua
local units = math.ceil(math.max(inputWidth / aspectWidth, inputHeight / aspectHeight))
local outputWidth = units * aspectWidth
local outputHeight = units * aspectHeight
```

Keep the aspect policy explicit instead of burying one-off constants in shader code.

## Transform Lifecycle

Prefer computing transforms in Lua and passing the final matrix to shader passes.

Classify each transform by dependencies:

- Reset-invariant: input/output size, fixed layout policy, assets, or reset-scope allocations. Compute in `onReset`.
- Frame-varying: time, animation phase, frame state, or live parameter values. Compute the final matrix in `advance`.
- Mixed: compute a stable base matrix in `onReset`, then copy and combine it with frame-varying transforms in `advance`.

Use Ring's `mat4` helpers (`identity`, `copy`, `translate`, `scale`, `rotateZ`, `multiply`, `preMultiply`, etc.) instead of manually writing 16 matrix elements unless there is a strong reason.

Do not store runtime objects such as `Input`, `Output`, or `Target` across resets. Store ordinary tables, matrices, dimensions, ids, or scalar state.

The existing sample `filter-samples/hdr-luminance-remap/main.lua` is a useful style reference for base-layout and per-frame-copy patterns: `matOriginal` is reset-invariant, `matLayoutCopy` is a working frame matrix, and `mat4.copy`/`scale`/`translate`/`rotateZ` split stable layout from animation.

## Vertex And Fragment Work

Put affine coordinate transforms in the vertex shader when interpolation preserves correctness:

```glsl
layout(location = 0) out vec2 v_ndc;
layout(location = 1) out vec2 v_source_uv;

void main() {
  v_ndc = a_position;
  v_source_uv = (params.ndcToSource * vec4(a_position, 0.0, 1.0)).xy;
  gl_Position = vec4(a_position, 0.0, 1.0);
}
```

Keep fragment shaders focused on work that is genuinely per-pixel: texture sampling, bounds masks, radial/sector decisions, nonlinear tests, and color transforms.

## Uniform Shape

Use the narrowest meaningful internal uniform:

- `float` for one scalar.
- `vec2` for width/height, aspect pair, or 2D direction.
- `vec3`/`vec4` only when every lane has meaning.
- `mat4` for explicit coordinate-space transforms.

Avoid passing redundant data just because a wider vector is convenient.
