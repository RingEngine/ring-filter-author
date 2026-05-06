# Ring Filter Author Skill

Local Codex skill for creating, refining, and validating Ring `filter-src` projects.

This skill is part of the Ring workspace update chain. When `docs`, `compiler-js`, or `forge` changes author-facing semantics, validation behavior, preview behavior, templates, or reusable implementation patterns, update this skill after those project changes are complete.

## Source Of Truth

- `docs/` and `docs/schemas/` define the runtime contract.
- `compiler-js/core` implements validation, reflection, and compile output.
- `forge` implements the authoring and preview experience.
- This skill explains and packages the current author workflow, but it must not redefine the standard.

## Repository

This directory is its own local git repository.

```text
skills/ring-filter-author/
```

The repository currently has no remote. Commit local updates here separately from `docs`, `compiler-js`, and `forge`.

## Contents

- `SKILL.md`: main skill instructions loaded by Codex.
- `references/`: focused authoring references for runtime semantics, parameters, transforms, and workflow.
- `assets/templates/`: starter `filter-src` projects.
- `agents/`: agent integration metadata.

## Ignored Living Snippets

Two self-iterating snippet libraries are intentionally ignored:

- `references/glsl-snippets.md`
- `references/lua-snippets.md`

Keep them ignored unless the user explicitly decides these living snippet histories should be versioned.

## Update Rules

1. Update `docs` first for contract or schema changes.
2. Sync implementation changes into `compiler-js` and `forge`.
3. Validate the project-specific behavior.
4. Update this skill to match the final behavior.
5. Commit this skill repository separately.

Keep README and reference updates concise. Do not add new ad hoc memory or snippet files when an existing reference file fits.
