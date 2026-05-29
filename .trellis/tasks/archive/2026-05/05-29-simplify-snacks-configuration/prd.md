# Simplify Snacks Configuration

## Goal

Simplify `lua/plugins/snacks.lua` by moving cohesive implementation details into small Snacks-specific Lua modules while preserving all current keymaps, terminal behavior, picker behavior, notifier options, and LSP progress notifications.

## Requirements

* Extract Snacks terminal behavior from `lua/plugins/snacks.lua` into a dedicated module under `lua/plugins/snacks/`.
* Extract the LSP progress notification autocmd from `lua/plugins/snacks.lua` into a dedicated module under `lua/plugins/snacks/`.
* Keep ordinary Snacks keymaps explicit in `lua/plugins/snacks.lua` for readability.
* Preserve the current terminal behavior:
  * normal-mode `<C-\>` toggles Snacks terminal using Snacks default count behavior.
  * terminal-mode `<C-\>` toggles the current Snacks terminal buffer, not terminal 1 by accident.
  * `<leader>tn` opens/toggles the next numbered terminal based on the current Snacks terminal list.
  * `<leader>ts` selects an existing Snacks terminal.
  * terminal `<Esc>`, `jk`, and `<C-h/j/k/l>` mappings remain scoped to Snacks terminal windows.
* Preserve current LSP progress notification formatting and spinner behavior.
* Do not change `claudecode.nvim` terminal behavior or introduce broad `TermOpen` mappings.

## Acceptance Criteria

* [ ] `lua/plugins/snacks.lua` is shorter and mainly contains the plugin spec, keymaps, and top-level opts.
* [ ] Terminal logic lives in a reusable Snacks terminal module and is required by `snacks.lua`.
* [ ] LSP progress autocmd setup lives in a Snacks LSP progress module and is required by `snacks.lua`.
* [ ] Existing Snacks terminal keymaps and behavior are preserved.
* [ ] `nvim --headless "+luafile init.lua" "+qa"` succeeds.
* [ ] A forced Snacks load check confirms terminal helpers/options can be required without errors.
* [ ] `git diff --check` succeeds.

## Definition of Done

* Implementation keeps behavior unchanged and only restructures code.
* Headless Neovim startup/load checks pass.
* No unused modules, stale ToggleTerm references, or broad terminal autocmds are introduced.
* Changes are committed only after quality checks pass and user asks for commit.

## Technical Approach

Create focused modules below `lua/plugins/snacks/`:

* `terminal.lua` returns terminal-related key handlers/options, including `toggle`, `toggle_next`, `select`, and `options` helpers.
* `lsp_progress.lua` exposes a setup function for the existing `LspProgress` autocmd.
* `snacks.lua` requires these modules once near the top, uses terminal helper functions in keymaps/options, and calls the LSP progress setup function from `init`.

## Decision (ADR-lite)

**Context**: `lua/plugins/snacks.lua` currently mixes plugin declaration, keymaps, terminal implementation details, and LSP progress notification logic, making the file long and harder to scan.

**Decision**: Extract only the cohesive implementation-heavy parts: terminal helpers and LSP progress setup. Keep ordinary keymaps and simple options explicit in the plugin spec.

**Consequences**: The main Snacks config becomes easier to read while avoiding over-abstraction. The trade-off is two small helper modules, but each module owns one clear concern.

## Out of Scope

* Changing Snacks keybindings or descriptions.
* Reworking picker, dashboard, notifier, or git keymaps beyond necessary require wiring.
* Changing terminal UX semantics from the current Snacks-based behavior.
* Replacing Snacks APIs or introducing new plugins.

## Technical Notes

* Current `lua/plugins/snacks.lua` contains terminal helpers at the top of the file and the LSP progress autocmd in `init`.
* The plugin loader imports `plugins` from `lua/config/lazy.lua`, so helper modules under `lua/plugins/snacks/` can be required explicitly from `lua/plugins/snacks.lua`.
* Existing plugin files are mostly single-file specs; this refactor introduces a small Snacks-specific helper folder only because Snacks now owns multiple independent behaviors.
* No current `require("plugins.*")` split-module pattern was found in `lua/`, so names should stay simple and local to Snacks to avoid broader convention changes.
