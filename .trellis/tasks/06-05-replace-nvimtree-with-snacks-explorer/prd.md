# Replace nvim-tree with Snacks Explorer

## Goal

Replace the current `nvim-tree` file explorer with Snacks.nvim explorer in this Neovim config while preserving the existing `<leader>e` explorer workflow and avoiding stale integrations that still assume `NvimTree` buffers.

## What I already know

* User wants the next task to replace nvim-tree with Snacks explorer.
* The repo already uses `folke/snacks.nvim` eagerly in `lua/plugins/snacks.lua`, but `opts.explorer.enabled` is currently `false`.
* The existing nvim-tree spec is isolated in `lua/plugins/nvimtree.lua` and owns `<leader>e` via `:NvimTreeToggle`.
* Current nvim-tree behavior shows dotfiles, disables git signs, disables diagnostics, and enables filesystem watchers with ignored watcher directories.
* `bufferline.nvim` currently offsets the tabline for filetype `NvimTree`.
* `claudecode.nvim` exposes `ClaudeCodeTreeAdd` only for supported tree filetypes; installed claudecode does not support Snacks explorer picker/list filetypes.

## Assumptions (temporary)

* Preserve the user-facing keybinding `<leader>e` for toggling/opening the explorer.
* Prefer minimal migration over unrelated keymap or UI redesign.
* User explicitly prefers adopting Snacks default explorer experience, with extra attention to keymaps.
* Do not hand-edit `lazy-lock.json`; let lazy.nvim update lock state if/when the plugin graph changes.

## Open Questions

* None.

## Requirements (evolving)

* Remove or disable the `nvim-tree/nvim-tree.lua` plugin spec.
* Enable Snacks explorer in the existing Snacks plugin spec.
* Map `<leader>e` to the documented Snacks API: `function() Snacks.explorer() end`.
* Adopt Snacks explorer default visibility behavior: hidden/dotfiles remain hidden by default and can be toggled with Snacks explorer's built-in `H` mapping.
* Replace nvim-tree-specific integration assumptions in bufferline and claudecode configs.
* Avoid duplicate keymaps and keep plugin-owned keymaps with the relevant plugin spec.
* Place Snacks explorer-specific code under `lua/plugins/snacks/`, following the existing `terminal.lua` / `lsp_progress.lua` module pattern.
* Review keymaps explicitly: preserve `<leader>e` as the explorer entry, leave Snacks explorer internal buffer-local keymaps at upstream defaults, avoid conflicts with existing global mappings, and do not make unsupported Snacks explorer actions appear as working keymaps.

## Acceptance Criteria (evolving)

* [ ] `nvim-tree/nvim-tree.lua` is no longer loaded by lazy.nvim config.
* [ ] `<leader>e` opens/toggles Snacks explorer.
* [ ] Snacks explorer is enabled under the existing `folke/snacks.nvim` config.
* [ ] Existing nvim-tree references are removed or intentionally replaced in Lua config.
* [ ] Snacks explorer uses upstream default hidden-file behavior unless explicitly toggled at runtime.
* [ ] Snacks explorer keeps upstream default git and diagnostic indicators enabled.
* [ ] Bufferline offset is updated for Snacks explorer or intentionally removed.
* [ ] ClaudeCode tree-add keymap is not left pointing at unsupported Snacks filetypes without working support.
* [ ] Snacks explorer helper/config lives under `lua/plugins/snacks/` and is required by `lua/plugins/snacks.lua`.
* [ ] Keymap review confirms `<leader>e` is unique in normal Neovim config and Snacks explorer internal mappings are intentionally left at upstream defaults.
* [ ] `nvim --headless` config load check passes.

## Definition of Done (team quality bar)

* Tests/checks run: at minimum a headless Neovim startup/config load check.
* Lint/typecheck where available.
* Docs/notes/spec updates only if behavior or project conventions change.
* Temporary files, stale imports, debug logs, and dead plugin config removed.

## Out of Scope (explicit)

* Replacing Snacks picker/file search keymaps beyond what is needed for explorer migration.
* Redesigning the full leader-key layout.
* Adding a new file explorer plugin other than Snacks explorer.
* Hand-editing generated lockfile entries unless required for a broken lock state.

## Research References

* [`research/snacks-explorer.md`](research/snacks-explorer.md) — Snacks explorer is a picker-backed explorer; migration needs `opts.explorer`, `opts.picker.sources.explorer`, `<leader>e` Lua API, and careful handling of bufferline/claudecode integrations.
* Context7 `/folke/snacks.nvim` docs — Confirms `Snacks.explorer()` keymap usage and explorer picker options: `hidden`, `git_status`, `diagnostics`, `watch`, `exclude`, `include`, `replace_netrw`.

## Research Notes

### What similar tools/docs indicate

* Snacks explorer is enabled through the Snacks plugin config, not a separate plugin spec.
* Documented keymap shape is `{ "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" }`.
* Explorer picker options live under `opts.picker.sources.explorer`.
* Snacks explorer defaults differ from current nvim-tree behavior: hidden files are hidden by default, git status is enabled by default, diagnostics are enabled by default, and watchers are enabled.
* Snacks explorer does not expose a unique stable explorer filetype; picker/layout windows use shared filetypes such as `snacks_picker_list` and `snacks_layout_box`.

### Constraints from this repo/project

* `lua/plugins/snacks.lua` already imports helper modules from `lua/plugins/snacks/` (`terminal.lua` and `lsp_progress.lua`); placing explorer-specific helper/config there follows the current style.
* `.trellis/spec/frontend/quality-guidelines.md` says plugin-owned keymaps should stay with the plugin spec and leader groups should be defined before child mappings.
* `lua/plugins/bufferline.lua` currently has `offsets = { { filetype = "NvimTree" } }`, which must not remain stale.
* `lua/plugins/claudecode.lua` currently scopes `ClaudeCodeTreeAdd` to supported tree filetypes. Installed claudecode has no Snacks explorer support, so simply adding Snacks filetypes would expose a failing command.

### Feasible approaches here

**Approach A: Strict parity migration** (Recommended)

* How it works: remove nvim-tree, enable Snacks explorer, keep `<leader>e`, set explorer picker options to match current behavior (`hidden = true`, `git_status = false`, `diagnostics = false`, `watch = true`), update bufferline offset, and avoid unsupported claudecode Snacks tree-add wiring.
* Pros: lowest surprise; mirrors current explorer behavior while reducing plugin count.
* Cons: does not immediately use Snacks git/diagnostic explorer features.

**Approach B: Adopt Snacks defaults**

* How it works: remove nvim-tree, enable Snacks explorer mostly with defaults, keep `<leader>e`, and accept hidden dotfiles plus git/diagnostic indicators.
* Pros: closer to upstream Snacks experience and richer explorer UI.
* Cons: changes behavior relative to current config; dotfiles become hidden by default unless toggled with `H`.

**Approach C: Migration plus local ClaudeCode tree-add support**

* How it works: do Approach A or B and add local logic so `<leader>as` can add the selected Snacks explorer item to ClaudeCode despite upstream claudecode not supporting it yet.
* Pros: preserves AI tree-add workflow from the explorer.
* Cons: more moving parts and more fragile because Snacks explorer picker buffers do not have a unique explorer-only filetype.

## Expansion Sweep

### Future evolution

* Snacks explorer can later expose richer git/diagnostic navigation if desired.
* If upstream claudecode adds Snacks support, local workaround can be removed or the keymap can be expanded safely.

### Related scenarios

* Directory-start behavior (`nvim .`) may be handled by Snacks explorer through `replace_netrw`.
* Bufferline offset should remain consistent with whichever explorer sidebar/window representation is used.

### Failure & edge cases

* Filetype-only integrations may accidentally match non-explorer Snacks pickers because picker filetypes are shared.
* Watcher behavior is not a one-to-one match with nvim-tree; if flicker appears, `watch = false` is the known fallback.

## Technical Approach

Use Approach B: adopt Snacks explorer defaults. Remove the separate nvim-tree plugin spec, add a new Snacks explorer helper/config module under `lua/plugins/snacks/`, require it from `lua/plugins/snacks.lua`, enable Snacks explorer in the existing Snacks plugin spec, map `<leader>e` through that helper to `Snacks.explorer()`, keep Snacks explorer's upstream default picker behavior for hidden files, git status, diagnostics, watch, directory/netrw replacement, and internal buffer-local explorer keymaps, then clean up stale nvim-tree integrations.

## Decision (ADR-lite)

**Context**: `nvim-tree` is currently the explorer, but Snacks is already installed and has an explorer module. Existing integrations assume `NvimTree` filetype.

**Decision**: Adopt Snacks explorer default experience instead of strict nvim-tree parity, with explicit keymap review before implementation.

**Consequences**: Dotfiles become hidden by default unless toggled with `H`; git and diagnostic indicators are enabled by default; watcher behavior follows Snacks defaults. Migration must avoid stale `NvimTree` keymaps/integrations and avoid exposing unsupported `ClaudeCodeTreeAdd` behavior for Snacks explorer.

## Technical Notes

* Inspected `lua/plugins/nvimtree.lua`, `lua/plugins/snacks.lua`, `lua/plugins/bufferline.lua`, `lua/plugins/claudecode.lua`, and `lua/core/mappings.lua`.
* Relevant current files:
  * `lua/plugins/nvimtree.lua` — old explorer spec.
  * `lua/plugins/snacks.lua` — target Snacks config.
  * `lua/plugins/bufferline.lua` — stale offset integration.
  * `lua/plugins/claudecode.lua` — stale/unsupported tree-add integration.
* Research persisted at `.trellis/tasks/06-05-replace-nvimtree-with-snacks-explorer/research/snacks-explorer.md`.
