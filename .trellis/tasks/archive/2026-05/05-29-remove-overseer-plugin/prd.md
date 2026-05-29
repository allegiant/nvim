# Remove Overseer Plugin

## Goal

Remove `stevearc/overseer.nvim` because the task runner UI is not useful enough for this config, and avoid leaving behind Overseer-only template files.

## Requirements

* Delete `lua/plugins/overseer.lua`.
* Delete the orphaned Overseer user template `lua/overseer/template/user/lua_run.lua`.
* Do not add replacement task-runner mappings or plugin configuration.
* Preserve Neovim startup behavior.

## Acceptance Criteria

* [x] `lua/plugins/overseer.lua` is removed.
* [x] `lua/overseer/template/user/lua_run.lua` is removed.
* [x] No active Lua config references `overseer`, `Overseer`, or `<leader>r` task mappings.
* [x] Headless Neovim startup succeeds.

## Definition of Done

* Relevant frontend specs reviewed before implementation.
* Working tree only contains the intended removal and Trellis task metadata before commit.
* Startup validation is run.

## Technical Approach

Delete the Overseer lazy.nvim spec and the custom template that is only loaded by that spec.

## Decision (ADR-lite)

**Context**: The user does not find the Overseer task runner useful. The config only exposes Overseer through `<leader>r` mappings and a single `user.lua_run` template.
**Decision**: Remove Overseer and its orphaned user template without replacing the workflow.
**Consequences**: `<leader>r` task runner mappings and `Overseer*` commands disappear; no task UI remains unless a future replacement is added.

## Out of Scope

* Replacing Overseer with `:make`, Snacks terminal, or custom `vim.system()` helpers.
* Changing unrelated terminal, picker, or DAP configuration.
* Editing lockfiles unless validation shows it is required.

## Technical Notes

* Inspected `lua/plugins/overseer.lua`.
* Inspected `lua/overseer/template/user/lua_run.lua`.
* Searched for `overseer` and `Overseer` references.
* Read frontend plugin configuration and quality guidelines.
