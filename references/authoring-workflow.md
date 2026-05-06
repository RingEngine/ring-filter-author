# Ring Filter Authoring Workflow

## Project Shape

A `filter-src` project has required root files:

```text
my-filter/
  manifest.json
  main.lua
  shaders/
    fullscreen.vert.glsl
    effect.frag.glsl
```

Use `docs/FILTER_SRC.md` and `docs/schemas/filter-src.schema.json` as the source of truth. Keep `$schema` optional unless the task benefits from editor validation.

## Manifest Checklist

- Use `"schemaVersion": "1.0.0"` and `"runtimeVersion": 1` for the current stable line unless docs say otherwise.
- Use `"metadata.kind": "filter-src"` when metadata is present.
- Choose `"outputSizeMode": "passive"` unless Lua must set output dimensions during `onReset(ctx, outputRequest)`.
- Declare every pass used by Lua.
- Use project-relative paths for shaders and assets.
- Keep pass ids stable and valid: start with a letter, then letters, digits, or underscores.

## Implementation Choices

Use one render pass when the effect can sample the input and write the final color directly.

Use multiple render passes when the effect needs intermediate targets, staged blurs, masks, overlays, or layout composition. Create intermediate targets in `onReset` with `ctx:createTarget(id, width, height)` and retrieve them with `ctx:getTarget(id)`.

Use compute passes when the filter needs data-domain work: histograms, reductions, lookup-table generation, per-pixel scatter, or storage-buffer output. Create buffers in `onReset` with `ctx:createFloatBuffer` or `ctx:createUIntBuffer`.

Use assets only when the effect needs user-independent images or videos. Declare them in `manifest.json` and access them in Lua with `ctx:getAsset(id)`.

## Validation

For filter-only work, compile the filter source directory with the compiler CLI from `compiler-js`:

```powershell
cd compiler-js
npx rfc2 compile --input ..\path\to\filter-src --output ..\path\to\compiled-out
```

If the CLI is unavailable but dependencies are installed, prefer existing compiler-js test or script patterns over inventing a new validator.

For compiler changes, run:

```powershell
cd compiler-js
npm run release:check
```

For Forge webview source changes, run Forge's check script and rebuild committed output according to the repo instructions.
