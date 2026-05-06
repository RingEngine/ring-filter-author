# Ring Parameter Patterns

## Core Rule

Parameters are the public authoring and host interface. They do not directly define shader uniforms. Lua reads parameters with `ctx:getParam(id)` and decides how they map into pass bindings, uniform blocks, resources, targets, or control flow.

## Types

Use `float` for continuous scalar controls. Provide `min`, `max`, and `default` when the UI range matters.

Use `bool` for toggles. Do not add `min`, `max`, or `semantic`.

Use `vec4` for colors and NDC UI controls. Use a semantic when the editor should know how to present or constrain the value.

Use `mat4` only when the public interface really needs a matrix. Most transform matrices should be author-owned Lua state or derived uniforms, not public parameters.

## Semantics

`color3` uses RGB in components 0-2 and fixes component 3 to `1`.

`color4` uses RGBA-like channels in components 0-3.

`ndcPoint2` uses `[x, y, 0, 1]`, with x and y in `[-1, 1]`. Ring NDC uses `[-1, -1]` at the upper-left corner and `[1, 1]` at the lower-right corner.

`ndcRect` uses `[x, y, w, h]`. `(x, y)` is the upper-left NDC corner, `w` extends right, and `h` extends downward. `w` and `h` must be `>= 0`.

## Naming

Use stable ids that are valid manifest ids: start with a letter, then letters, digits, or underscores.

Use user-facing `label` strings for Forge and host UI clarity. Labels do not affect runtime behavior.

Prefer parameter ids that describe intent, not shader implementation details: `strength`, `tintColor`, `center`, `region`, `radius`, `enabled`.

## Defaults

Choose defaults that produce a visible but not destructive effect.

For `float`, keep defaults inside the resolved `[min, max]` range.

For color controls, use normalized channel values.

For `ndcRect`, choose non-negative width and height. A small centered default can be `[-0.25, -0.25, 0.5, 0.5]`.
