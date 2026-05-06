---
name: ring-filter-author
description: Create, refine, and validate Ring Engine filter-src projects. Use when Codex is asked to make a new Ring filter from a visual effect description, edit an existing filter manifest/main.lua/shader set, design public filter parameters, implement Lua pass orchestration, write GLSL render or compute passes for Ring, validate compiler or Forge preview behavior for a filter, or adapt filter-samples while preserving docs-level runtime semantics.
---

# Ring Filter Author

## Overview

Use this skill to turn an effect idea into a Ring `filter-src` project, or to change an existing filter without drifting away from the documented runtime contract.

Keep the skill lean: load Ring docs and references only when the task needs them, then implement and validate against the compiler and Forge expectations.

## Source Of Truth

- Treat `docs/` and `docs/schemas/` as the source of truth for runtime contract, schemas, Lua APIs, GLSL semantics, coordinate conventions, `time`, `random`, `mat4`, and author-facing behavior.
- Treat `compiler-js/core` as the implementation of those docs in validation, reflection, and compile outputs.
- Treat Forge as a docs-aware authoring surface that consumes compiler-produced WGSL for `backend: 'web-preview'`.
- Treat `filter-samples` as validation material. Do not modify sample filters unless the user explicitly asks.
- Do not use `web-editor` as part of the default authoring or validation path unless the user explicitly asks.

## Workflow

1. Identify the user goal: visual effect, input media assumptions, public parameters, animation needs, output size behavior, and whether an existing filter should be preserved.
2. Inspect the target filter files before editing. For a new filter, choose an appropriate template from `assets/templates/`.
3. Load the narrow reference needed for the current task:
   - Read `references/authoring-workflow.md` for project structure and implementation choices.
   - Read `references/runtime-semantics.md` for Lua, shader, coordinate, timing, and reset-boundary semantics.
   - Read `references/transform-patterns.md` when the effect involves layout, resizing, letterboxing, cropping, coordinate-space mapping, `mat4`, vertex varyings, or source/output transforms.
   - Read `references/glsl-snippets.md` when shader code needs UV bounds handling, border fill, clamp/repeat/mirror behavior, masks, aspect-correct coordinates, or reusable color helpers.
   - Read `references/lua-snippets.md` when Lua pass orchestration, reset-time allocation, parameter mapping, matrix setup, or repeated runtime binding patterns need reusable examples.
   - Read `references/parameter-patterns.md` when designing or changing `parameters`.
4. Implement the smallest filter shape that matches the effect:
   - Use one render pass for direct source-to-output image effects.
   - Add reset-scope targets for multi-pass effects.
   - Add compute passes and buffers only for data-domain work such as histograms or reductions.
   - Use `outputSizeMode: "active"` only when the filter must choose output dimensions.
5. Validate with the compiler. Prefer a direct compile of the edited filter source directory. If compiler behavior changed, run `npm run release:check` inside `compiler-js`.
6. For Forge-impacting changes, keep Forge preview on compiler-produced `backend: 'web-preview'` WGSL. Do not restore a Forge-side GLSL-to-WGSL fallback.
7. When the work produces a reusable shader, Lua, matrix, parameter, or validation pattern that is not yet captured by this skill, mention it in the final response as a candidate for the relevant skill reference. Add it to the skill only when the user agrees or explicitly asks, so the snippet library grows under the user's control.
8. Put self-iterating code snippets only in the fixed files `references/glsl-snippets.md` and `references/lua-snippets.md`. Do not create ad hoc memory/snippet files with new names; stable filenames make future Git include/ignore rules predictable.

## Authoring Rules

- Keep `manifest.json`, `main.lua`, and shader source in agreement. Pass ids, shader binding names, Lua binding keys, parameter ids, buffer ids, target ids, and asset ids must match exactly.
- Do not expose shader uniforms directly as parameters by habit. Parameters are host/Lua public controls; Lua decides how they map into pass bindings.
- Use project-relative paths in manifests. Do not write absolute shader or asset paths.
- Use `onReset` for reset-scope allocation and state initialization. Use `advance(ctx)` for per-frame execution.
- Use `runtimeHints.frameInvalidation: "continuous"` when a filter may animate or otherwise change as the render timeline advances without input or parameter changes.
- Do not keep `Target`, `Buffer`, `Input`, `Output`, `Image`, or `Video` runtime objects as Lua globals across resets.
- Do not keep array tables returned by `ctx:getParam(id)` as persistent state. Copy them into author-owned Lua tables when persistence is needed.
- Ring NDC follows Vulkan-style y-down viewport semantics: `[-1, -1]` is the upper-left corner, `[1, 1]` is the lower-right corner, and texture UVs use `[0, 0]` upper-left to `[1, 1]` lower-right.
- For `ndcRect`, represent rectangles as `[x, y, w, h]`, where `(x, y)` is the upper-left NDC corner, `w` extends toward positive x, and `h` extends downward toward positive y.
- Prefer semantically meaningful coordinate spaces. Use NDC for output-domain geometry and center/radial effects, source UV for input sampling, and pixel space when aspect-correct distance or angle matters. Do not introduce `v_uv = a_position * 0.5 + 0.5` by habit when a non-trivial layout transform exists.
- Prefer computing transform matrices in Lua with `mat4` helpers, then pass the final matrix to shaders. Compute reset-invariant matrices in `onReset`; for animated or parameter-varying transforms, precompute invariant bases in `onReset` and combine the final matrix in `advance`.
- Use `ctx:getTimeSeconds()`, `ctx:getDeltaSeconds()`, and `ctx:getFrameIndex()` for animation. Use `time.now()` only for wall-clock or calendar behavior such as date-based variants.
- Put affine coordinate transforms in the vertex shader when interpolation is valid. Keep fragment shader work for per-pixel sampling, masks, nonlinear tests, and color changes.
- Use narrow internal uniforms: `float` for scalar values, `vec2` for size/aspect pairs, `vec4` only when all four lanes carry meaning.
- Prefer shared GLSL snippet patterns for common UV and mask behavior instead of re-inventing ad hoc boundary logic in every shader.
- Surface newly discovered reusable snippets or patterns as candidates; do not add them to the skill without user agreement.
- When adding approved GLSL snippet content, update `references/glsl-snippets.md`; do not create another GLSL memory/snippet file.
- When adding approved Lua snippet content, update `references/lua-snippets.md`; do not create another Lua memory/snippet file.
- If valid GLSL compiles for SPIR-V but Forge/web-preview fails, identify it as a compiler/backend issue. Do not rewrite correct shader architecture solely to hide compiler bugs unless the user asks for a workaround.

## Templates

Use templates as starting points, then rename metadata, ids, labels, and effect logic:

- `assets/templates/minimal-render-filter/`: one render pass, one `float` parameter, passive output size.
- `assets/templates/animated-tint-filter/`: one render pass, `color4` and speed parameters, Lua-driven time uniform.

After copying a template, validate before expanding it. A compiling simple filter is a better base than a complex unverified one.
