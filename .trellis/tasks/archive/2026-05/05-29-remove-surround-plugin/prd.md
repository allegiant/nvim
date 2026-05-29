# Remove Surround Plugin

## Goal

Remove `kylechui/nvim-surround` because the surround editing workflow is not used enough in this configuration.

## Requirements

* Delete `lua/plugins/surround.lua`.
* Do not add replacement surround mappings or plugin configuration.
* Preserve Neovim startup behavior.

## Acceptance Criteria

* [x] `lua/plugins/surround.lua` is removed.
* [x] No active Lua config references `nvim-surround` or `require("nvim-surround")`.
* [x] Headless Neovim startup succeeds.

## Definition of Done

* Relevant frontend specs reviewed before implementation.
* Working tree only contains the intended removal and Trellis task metadata before commit.
* Startup validation is run.

## Technical Approach

Delete the lazy.nvim plugin spec and rely on built-in text-object editing when needed.

## Decision (ADR-lite)

**Context**: The user does not use surround editing enough to justify keeping the plugin. The current config only loads `kylechui/nvim-surround` with default setup.
**Decision**: Remove the plugin spec without replacement.
**Consequences**: Default surround operations such as `ys`, `cs`, and `ds` are no longer available; no equivalent workflow is added.

## Out of Scope

* Replacing surround with `mini.surround`, `vim-surround`, or custom keymaps.
* Changing which-key operator/motion presets.
* Editing lockfiles unless validation shows it is required.

## Technical Notes

* Inspected `lua/plugins/surround.lua`.
* Searched active Lua config for `nvim-surround`, `surround`, and common default surround keys.
* Read frontend plugin configuration and quality guidelines.
