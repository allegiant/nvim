# Remove mini.comment Plugin

## Goal

Remove the redundant `mini.comment` plugin configuration because the current Neovim version provides built-in commenting and no repo code depends on this plugin.

## Requirements

* Delete `lua/plugins/mini.lua`.
* Do not add replacement mappings or new plugin configuration.
* Preserve existing Neovim startup behavior.

## Acceptance Criteria

* [x] `lua/plugins/mini.lua` is removed.
* [x] No remaining Lua config references `mini.comment`.
* [x] Headless Neovim startup succeeds.

## Definition of Done

* Relevant specs reviewed before implementation.
* Working tree only contains the intended removal and Trellis task metadata.
* Startup validation is run.

## Technical Approach

Delete the unused lazy.nvim spec file and rely on Neovim's built-in commenting behavior.

## Decision (ADR-lite)

**Context**: `lua/plugins/mini.lua` only loads `nvim-mini/mini.comment` with default setup, while Neovim v0.12.2 already includes built-in comment mappings.
**Decision**: Remove the plugin spec instead of replacing it.
**Consequences**: Lazy will no longer install/load `mini.comment`; built-in `gc`/`gcc` commenting remains available.

## Out of Scope

* Changing keymaps.
* Running `:Lazy clean` automatically.
* Editing lockfiles unless validation shows it is required.

## Technical Notes

* Inspected `lua/plugins/mini.lua`.
* Searched Lua config for `mini`, `mini.comment`, `comment`, `gcc`, and `gc` references.
* Read frontend plugin configuration guidelines and shared code reuse guide.
