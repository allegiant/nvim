# 优化 claude-code.nvim 配置

## Goal

Fix the Claude Code terminal interaction so using Esc to leave terminal insert mode / return to Neovim normal mode does not interrupt or break the running Claude session, while preserving predictable terminal navigation in the rest of this Neovim config.

## What I already know

- User reports the current problem: pressing Esc to return to normal mode interrupts Claude.
- User corrected the plugin reference: the intended plugin is `https://github.com/coder/claudecode.nvim`.
- Local config already uses `coder/claudecode.nvim` in `lua/plugins/claudecode.lua`.
- Local `lua/plugins/claudecode.lua` uses `config = true` and only defines leader keymaps; there is no existing custom `coder/claudecode.nvim` configuration or `opts` table.
- Local `lua/plugins/toggleterm.lua` installs terminal-mode `<esc>` and `jk` mappings for every `TermOpen term://*` buffer via `_G.set_terminal_keymaps()`.
- Research found `coder/claudecode.nvim` has no implemented `cancel_key`/terminal-Esc option; user config must handle terminal-mode remapping.
- Research found ToggleTerm documentation explicitly supports scoping terminal keymaps to ToggleTerm-owned buffers with `term://*toggleterm#*`; the local config currently uses broad `term://*`, affecting Claude terminal buffers too.
- The earlier `greggh` reference is out of scope because the user confirmed it was the wrong document.

## Research References

- [`research/claude-code-nvim-esc.md`](research/claude-code-nvim-esc.md) — terminal Esc behavior notes and the correction that this repo uses `coder/claudecode.nvim`.
- [`research/coder-claudecode-config.md`](research/coder-claudecode-config.md) — `coder/claudecode.nvim` setup/options, terminal providers, lack of Esc/cancel option, and buffer-aware mapping approach.
- [`research/toggleterm-keymaps.md`](research/toggleterm-keymaps.md) — ToggleTerm terminal keymap docs, including broad `term://*` versus ToggleTerm-only `term://*toggleterm#*` scoping.

## Assumptions (temporary)

- The immediate goal is to stop Esc from sending an interrupt/control behavior to Claude or otherwise disrupting the Claude terminal session.
- The fix should be scoped to Claude terminal behavior if possible, rather than weakening terminal navigation everywhere.
- Existing AI leader mappings under `<leader>a` should be preserved unless the plugin changes require command updates.

## Open Questions

- None.

## Requirements (evolving)

- Preserve existing `<leader>a...` Claude Code command mappings where compatible.
- Avoid breaking general terminal workflows in `toggleterm.nvim`.
- Add the minimum necessary `coder/claudecode.nvim` configuration or buffer-local key handling; do not invent options that are not documented/supported.
- Verify Neovim startup still succeeds after the change.

## Acceptance Criteria (evolving)

- [x] ToggleTerm terminal mappings are scoped to `term://*toggleterm#*` per ToggleTerm documentation.
- [x] Claude terminal buffers no longer inherit ToggleTerm's `<Esc>` terminal mapping.
- [x] Pressing Esc repeatedly in the Claude terminal does not exit/interrupt Claude.
- [x] Esc in the Claude terminal safely returns to Neovim terminal-normal mode instead of being sent to Claude.
- [x] There is still a reliable fallback way to leave Claude terminal insert mode and return to Neovim normal mode (`<C-\\><C-n>`).
- [x] Existing Claude Code leader mappings remain unchanged.
- [x] General ToggleTerm mappings in `lua/plugins/toggleterm.lua` still apply to ToggleTerm-owned terminals.
- [x] `nvim --headless "+luafile init.lua" "+qa"` passes.

## Definition of Done

- Code/config changed in the appropriate plugin file(s).
- Lightweight verification run and results recorded.
- Spec updated if we establish a reusable terminal/AI-plugin convention.
- Changes committed after review.

## Out of Scope

- Reworking all terminal keymaps unrelated to Claude.
- Changing non-Claude AI workflow behavior.
- Adding new dependencies beyond the selected Claude Code plugin unless required.

## Decision (ADR-lite)

**Context**: `coder/claudecode.nvim` runs Claude in a terminal buffer, while this repo's `lua/plugins/toggleterm.lua` currently applies ToggleTerm terminal-mode mappings to every `term://*` buffer. ToggleTerm docs explicitly show `term://*toggleterm#*` when mappings should apply only to ToggleTerm-owned terminals.

**Decision**: Scope `_G.set_terminal_keymaps()` to ToggleTerm-owned terminal buffers by changing the `TermOpen` pattern from `term://*` to `term://*toggleterm#*`, then add Claude-specific terminal Esc handling so Esc is not passed through to the Claude process.

**Consequences**: ToggleTerm buffers keep their Esc/window navigation mappings; Claude terminal buffers no longer inherit ToggleTerm's broad mapping and get their own safe Esc-to-terminal-normal behavior. Other non-ToggleTerm terminal buffers also stop receiving ToggleTerm convenience mappings, which is intentional because they are not owned by ToggleTerm.

## Technical Approach Options

### Option A: Scope ToggleTerm keymaps to ToggleTerm-owned terminals (Selected)

- Keep current `coder/claudecode.nvim` package and do not invent unsupported Claude options.
- Change the ToggleTerm `TermOpen` autocmd pattern from broad `term://*` to the documented ToggleTerm-only `term://*toggleterm#*`.
- Result: ToggleTerm buffers keep `<Esc>`, `jk`, and window navigation mappings; Claude terminal buffers no longer inherit ToggleTerm's `<Esc>` mapping.
- Pros: follows ToggleTerm docs, smallest and cleanest fix, avoids Claude-specific detection code.
- Cons: other non-ToggleTerm terminals will also stop inheriting these ToggleTerm convenience mappings.

### Option B: Add Claude-buffer-aware `<Esc>` guard (Selected follow-up)

- Keep ToggleTerm scoped to `term://*toggleterm#*`.
- Add Claude-specific terminal `<Esc>` handling using `require("claudecode.terminal").get_active_terminal_bufnr()` or provider-specific documented config so Esc maps to `<C-\\><C-n>` for the active Claude terminal.
- Pros: prevents raw Esc from reaching Claude while keeping ToggleTerm mappings scoped correctly.
- Cons: couples the local config to Claude Code's terminal buffer helper.

### Option C: Remove global terminal `<esc>` mapping for all terminal buffers

- Leave Claude plugin mostly untouched.
- Remove or replace the global `toggleterm.lua` `<esc>` terminal mapping for all terminal buffers.
- Pros: simple and likely prevents Esc from being intercepted unexpectedly.
- Cons: changes terminal muscle memory globally and may be too broad.

## Technical Notes

- Current Claude config: `lua/plugins/claudecode.lua`.
- Global terminal mappings: `lua/plugins/toggleterm.lua`.
- Frontend specs relevant to keymaps/plugin UI: `.trellis/spec/frontend/component-guidelines.md`, `.trellis/spec/frontend/hook-guidelines.md`, `.trellis/spec/frontend/quality-guidelines.md`.
