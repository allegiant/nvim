# Remove Disabled fzf Plugin

## Goal

Remove the inactive `fzf-lua` plugin spec because it is disabled and its picker/LSP keymaps are already covered by the active Snacks configuration.

## Requirements

* Delete `lua/plugins/fzf.lua`.
* Do not change Snacks picker keymaps or behavior.
* Do not add replacement plugin configuration.
* Preserve Neovim startup behavior.

## Acceptance Criteria

* [x] `lua/plugins/fzf.lua` is removed.
* [x] No active Lua config references `fzf-lua` or `FzfLua`.
* [x] Headless Neovim startup succeeds.

## Definition of Done

* Relevant frontend specs reviewed before implementation.
* Working tree only contains the intended removal and Trellis task metadata before commit.
* Startup validation is run.

## Technical Approach

Delete the disabled lazy.nvim plugin spec and rely on the existing Snacks picker mappings.

## Decision (ADR-lite)

**Context**: `lua/plugins/fzf.lua` has `enabled = false` and duplicates active Snacks picker mappings.
**Decision**: Remove the inactive fzf-lua spec instead of keeping a disabled alternate picker configuration.
**Consequences**: Lazy no longer sees the disabled fzf-lua spec; Snacks remains the active picker implementation.

## Out of Scope

* Changing picker keymaps.
* Enabling or configuring Snacks explorer.
* Editing lockfiles unless validation shows it is required.

## Technical Notes

* Inspected `lua/plugins/fzf.lua` and `lua/plugins/snacks.lua`.
* Confirmed fzf-lua spec is disabled and overlaps with Snacks picker mappings.
* Read frontend plugin configuration and quality guidelines.
