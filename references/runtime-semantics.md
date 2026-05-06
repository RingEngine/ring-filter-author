# Ring Runtime Semantics

## Lua Entry Points

Use `onReset(ctx)` for passive output size mode.

Use `onReset(ctx, outputRequest)` for active output size mode, and call `outputRequest:setSize(width, height)` with positive integer dimensions.

Use `advance(ctx)` for per-frame execution.

`onReset` is the reset boundary. Runtime-created objects belong to the current reset scope.

## Lua Runtime Surface

Use only the runtime-documented global surface. `mat4` and `time` are runtime-injected globals. `os`, `io`, `package`, and `debug` are not part of the runtime contract.

Use `math.random(...)` and `math.randomseed(seed)` only with the understanding that random output is not repeatable unless explicitly seeded.

## Runtime Objects

Runtime objects include `Target`, `Buffer`, `Input`, `Output`, `Image`, and `Video`. Acquire or create them through `ctx`.

Do not keep runtime objects acquired through `ctx` as Lua globals across resets. Store ids or ordinary Lua state instead, then reacquire objects inside the relevant entry point.

## Parameters

`ctx:getParam(id)` returns the current public parameter value. Scalar values are plain Lua values.

Array parameters such as `vec4` and `mat4` return runtime-managed snapshot tables for the current Lua entry call. Do not store those returned tables as persistent state. Copy into an author-owned table when persistence or mutation is needed.

## Render Passes

Use:

```lua
ctx:runRenderPass("passId", {
  source = ctx:getInput(),
  params = {
    strength = ctx:getParam("strength")
  }
}, ctx:getOutput())
```

Uniform block bindings are Lua tables keyed by block member names. Sampled image bindings receive image-like runtime objects such as input, target, image, or video objects.

Clear outputs explicitly with `ctx:clearOutput(output, color)` when initial contents matter.

## Compute Passes

Use:

```lua
ctx:runComputePass("passId", bindings, { width, height })
```

The dispatch value is logical execution coverage, not native workgroup count. The compiler records shader `localSize`; the runtime converts logical dispatch to backend workgroup counts.

Storage buffer declarations must contain exactly one array member.

## Coordinate Semantics

Ring NDC follows Vulkan-style y-down viewport semantics: `[-1, -1]` is the upper-left corner, `[1, 1]` is the lower-right corner, x grows right, and y grows downward. Texture UVs use `[0, 0]` upper-left to `[1, 1]` lower-right.

`ndcPoint2` is `[x, y, 0, 1]`, with `x` and `y` in normalized device coordinates `[-1, 1]`.

`ndcRect` is `[x, y, w, h]`, where `(x, y)` is the upper-left corner in normalized device coordinates, `w` extends toward positive x, and `h` extends downward toward positive y. Only `w` and `h` are algebraically constrained by schema; they must be greater than or equal to `0`.

## Matrices

`mat4` values are ordinary Lua tables containing exactly 16 numbers in column-major order, matching GLSL `mat4` uniforms.

Create author-owned matrix tables directly:

```lua
local transform = {}

function onReset(ctx)
  mat4.identity(transform)
end
```

Use `mat4.identity`, `copy`, `multiply`, `preMultiply`, `translate`, `scale`, `rotateX`, `rotateY`, `rotateZ`, `setTranslation`, `setScale`, `setRotationX`, `setRotationY`, `setRotationZ`, `setOrtho`, `invert`, `transpose`, `transformPoint4`, and `transformPoint2` according to docs.

## Time

`ctx:getFrameIndex()` returns the zero-based logical frame index for the current `advance(ctx)` call.

`ctx:getTimeSeconds()` returns the logical render time in seconds for the current `advance(ctx)` call.

`ctx:getDeltaSeconds()` returns the logical elapsed time since the previous `advance(ctx)` call in the same reset scope. The first frame after reset returns `0`.

Use the `ctx` timeline functions for animation and frame-dependent rendering. If a filter may change as this timeline advances without input or parameter changes, set `runtimeHints.frameInvalidation` to `"continuous"` in `manifest.json`.

`time.now()` returns Unix timestamp seconds. It is wall-clock time, separate from render timeline concepts such as frame time, delta time, and frame index.

Use `time.parts(out, timestamp, options)` when calendar fields are needed. Reuse the output table across frames if useful.
