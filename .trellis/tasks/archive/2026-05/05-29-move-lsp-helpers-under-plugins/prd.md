# Move LSP Helpers Under Plugins

## Goal

Move the Neovim LSP server helper modules from `lua/lsp/` into `lua/plugins/lsp/` so they follow the plugin-owned helper module pattern already used by Snacks, while preserving all current LSP behavior.

## Requirements

* Move all current LSP helper modules from `lua/lsp/*.lua` to `lua/plugins/lsp/*.lua`.
* Update `lua/plugins/lspconfig.lua` to require `plugins.lsp.*` modules.
* Update each moved LSP server module to require `plugins.lsp.utils` instead of `lsp.utils`.
* Preserve existing setup order and behavior for `lua_ls`, `jsonls`, `pylsp`, `vue_ls`, and `sqls`.
* Do not create `lua/plugins/lsp/init.lua`, because lazy.nvim imports direct plugin specs from `plugins` and directories with `init.lua`.
* Remove the old `lua/lsp/` helper files after the move.

## Acceptance Criteria

* [ ] `lua/lsp/` no longer contains the old helper modules.
* [ ] `lua/plugins/lsp/` contains `utils.lua`, `lua_ls.lua`, `jsonls.lua`, `pylsp.lua`, `sqls.lua`, and `vue_ls.lua`.
* [ ] No runtime references to `require("lsp.*")` remain.
* [ ] No `lua/plugins/lsp/init.lua` file exists.
* [ ] `nvim --headless "+luafile init.lua" "+qa"` succeeds.
* [ ] A forced `nvim-lspconfig` load / require check succeeds for all moved modules.
* [ ] `git diff --check` succeeds.

## Definition of Done

* The move is behavior-preserving and limited to module location/import path cleanup.
* Relevant Neovim headless load checks pass.
* No lazy.nvim plugin import ambiguity is introduced.
* No stale files or stale require paths remain.

## Technical Approach

Create `lua/plugins/lsp/`, move each existing file from `lua/lsp/` into it, and update require paths:

* `require("lsp.lua_ls")` → `require("plugins.lsp.lua_ls")`
* `require("lsp.jsonls")` → `require("plugins.lsp.jsonls")`
* `require("lsp.pylsp")` → `require("plugins.lsp.pylsp")`
* `require("lsp.vue_ls")` → `require("plugins.lsp.vue_ls")`
* `require("lsp.sqls")` → `require("plugins.lsp.sqls")`
* `require("lsp.utils")` → `require("plugins.lsp.utils")`

## Decision (ADR-lite)

**Context**: LSP helper modules are only used by `lua/plugins/lspconfig.lua`, so they are plugin-owned implementation details rather than shared top-level application modules.

**Decision**: Move the helper modules under `lua/plugins/lsp/`, matching the new `lua/plugins/snacks/` helper-module pattern.

**Consequences**: Plugin-owned configuration becomes colocated and easier to scan. The main risk is lazy.nvim import ambiguity, avoided by not adding `lua/plugins/lsp/init.lua`.

## Out of Scope

* Changing LSP server options, setup order, diagnostics, or keymaps.
* Renaming individual server helper files beyond path relocation.
* Adding new LSP servers or refactoring server configuration internals.
* Changing lazy.nvim plugin import configuration.

## Technical Notes

* `lua/plugins/lspconfig.lua` is the only caller of the current `require("lsp.*")` server modules.
* Current server modules require `lsp.utils`; those imports must move together with `utils.lua`.
* `lua/config/lazy.lua` imports `{ import = "plugins" }`; lazy.nvim scans direct files and directories with `init.lua`, so helper subdirectories without `init.lua` are safe.
