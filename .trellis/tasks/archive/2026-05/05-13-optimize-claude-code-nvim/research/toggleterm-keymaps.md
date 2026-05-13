# Research: toggleterm.nvim terminal keymaps and Claude terminal Esc issue

- **Query**: Research https://github.com/akinsho/toggleterm.nvim documentation/source for terminal-mode keymaps, recommended `<Esc>` / `<C-\\><C-n>` usage, `TermOpen` mappings, `open_mapping`, and whether toggleterm mappings should apply globally or only toggleterm-owned terminals. Map findings to this repo's `lua/plugins/toggleterm.lua` and the Claude terminal issue.
- **Scope**: mixed
- **Date**: 2026-05-13

## Findings

### Files Found

| File Path | Description |
|---|---|
| `lua/plugins/toggleterm.lua` | Local ToggleTerm plugin config. Defines terminal-mode mappings and installs them on `TermOpen term://*`. |
| `lua/plugins/claudecode.lua` | Local Claude Code plugin config using `coder/claudecode.nvim`; no terminal-specific keymap config in this file. |
| `.trellis/tasks/05-13-optimize-claude-code-nvim/prd.md` | Task context: Esc in Claude terminal interrupts/breaks session; current known issue includes `toggleterm.lua` installing `<esc>` mappings for every terminal. |
| `.trellis/tasks/05-13-optimize-claude-code-nvim/research/claude-code-nvim-esc.md` | Prior research on Claude terminal Esc behavior and local global terminal mapping. |
| `.trellis/tasks/05-13-optimize-claude-code-nvim/research/coder-claudecode-config.md` | Prior research on `coder/claudecode.nvim` terminal providers and buffer identification. |
| `.trellis/spec/frontend/component-guidelines.md` | Repo guideline: `lua/plugins/toggleterm.lua` owns terminal split/float behavior, highlights, and terminal-mode mappings. |
| `.trellis/spec/frontend/hook-guidelines.md` | Repo guideline: terminal buffer mappings are installed via `TermOpen` in `lua/plugins/toggleterm.lua`; named global functions only when command strings need them. |
| `.trellis/spec/frontend/quality-guidelines.md` | Repo guideline: preserve mode-specific keymaps and keep ToggleTerm-owned terminal mappings in `lua/plugins/toggleterm.lua`. |
| `.trellis/spec/frontend/state-management.md` | Repo guideline: terminal-local keymaps are buffer/window/filetype-local state in `lua/plugins/toggleterm.lua`. |
| `https://github.com/akinsho/toggleterm.nvim/blob/main/README.md` | Upstream README for `open_mapping`, terminal mappings, and `TermOpen` pattern. |
| `https://github.com/akinsho/toggleterm.nvim/blob/main/lua/toggleterm/config.lua` | Upstream defaults/types for `insert_mappings`, `terminal_mappings`, and related options. |

### Code Patterns

#### Local `toggleterm.lua` behavior

- `lua/plugins/toggleterm.lua:19-27` defines `_G.set_terminal_keymaps()` with buffer-local terminal-mode maps for the current terminal buffer:

```lua
function _G.set_terminal_keymaps()
  local opts = { buffer = 0 }
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
  vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
  vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
  vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
end
```

- `lua/plugins/toggleterm.lua:37-69` calls `require("toggleterm").setup({ ... })`. The relevant local option is `open_mapping = [[<c-\>]]` at `lua/plugins/toggleterm.lua:45`.
- `lua/plugins/toggleterm.lua:75` installs the mapping function for all Neovim terminal buffers matching `term://*`:

```lua
vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
```

- Because the autocmd pattern is `term://*`, these mappings are not limited to ToggleTerm-owned terminals. They apply to any terminal buffer opened through Neovim's terminal mechanism, including Claude terminal buffers if `coder/claudecode.nvim` creates or uses a regular Neovim terminal buffer.

#### Local Claude Code task context

- `.trellis/tasks/05-13-optimize-claude-code-nvim/prd.md:5` states the goal: fix Claude Code terminal interaction so Esc can leave terminal insert mode / return to Neovim normal mode without interrupting or breaking Claude.
- `.trellis/tasks/05-13-optimize-claude-code-nvim/prd.md:13` records the relevant local fact: `lua/plugins/toggleterm.lua` installs terminal-mode `<esc>` and `jk` mappings for every `TermOpen term://*` buffer.
- `lua/plugins/claudecode.lua:1-24` declares `coder/claudecode.nvim` with `config = true` and command keymaps only. There is no local option that changes Claude terminal Esc handling in this file.

#### Upstream ToggleTerm `open_mapping`

- ToggleTerm README lines 127-134 state that `require("toggleterm").setup{}` must explicitly enable the plugin, and `open_mapping` sets up mappings for normal mode. The option can be a string or array. The same section says `insert_mappings = true` makes the open mapping work in insert mode, and `terminal_mappings = true` makes it work in opened terminals.
- ToggleTerm README lines 161-164 show the documented setup example:

```lua
open_mapping = [[<c-\>]], -- or { [[<c-\>]], [[<c-¥>]] } if you also use a Japanese keyboard.
```

- ToggleTerm README lines 191-194 show documented defaults/options:

```lua
start_in_insert = true,
insert_mappings = true, -- whether or not the open mapping applies in insert mode
terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
persist_size = true,
```

- ToggleTerm source `lua/toggleterm/config.lua` lines 24-27 type `open_mapping` as `string | string[]` and include `insert_mappings` / `terminal_mappings` as boolean fields.
- ToggleTerm source `lua/toggleterm/config.lua` lines 48-53 default `insert_mappings = true`, `terminal_mappings = true`, and `start_in_insert = true`.

#### Upstream ToggleTerm terminal-window mappings

- ToggleTerm README lines 413-416 introduce terminal-window mappings as a way to make moving in and out of a terminal easier once toggled while keeping it open.
- ToggleTerm README lines 419-428 provide this example:

```lua
function _G.set_terminal_keymaps()
  local opts = {buffer = 0}
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
  vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
  vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
  vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
  vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
end
```

- The local config mirrors this upstream example except it omits the upstream example's `<C-w>` terminal-mode map.
- ToggleTerm README lines 430-431 are directly relevant to global-vs-ToggleTerm-only scope:

```lua
-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
```

- Interpretation of the documented pattern: `TermOpen term://*` is the broad pattern for all terminal buffers; `term://*toggleterm#*` is the upstream-documented narrower pattern when mappings should be limited to ToggleTerm-created terminals.

#### `<Esc>` and `<C-\\><C-n>` usage

- ToggleTerm's terminal-window mapping example maps terminal-mode `<esc>` to `[[<C-\><C-n>]]`. This is the Neovim terminal-mode escape sequence that leaves terminal insert mode and returns to terminal normal mode.
- ToggleTerm README documentation also states that to leave terminal mode, use `C-\ C-N`, and that it can be remapped to Esc for ease of use. The README search highlight from GitHub showed: "In your first terminal, you need to leave the `TERMINAL` mode using C-\\ C-N which can be remapped to Esc for ease of use."
- Mapping consequence for the Claude issue: with the current `TermOpen term://*` autocmd, `<Esc>` in any terminal buffer is intercepted by Neovim as a terminal-mode mapping and converted to `<C-\><C-n>`. If Claude or its terminal provider expects to receive raw Esc for in-process UI/cancel behavior, this broad mapping prevents raw Esc from reaching the Claude process; if the goal is only to leave terminal insert mode, the mapping matches ToggleTerm's documented example.

### External References

- [toggleterm.nvim README](https://github.com/akinsho/toggleterm.nvim/blob/main/README.md) — Documents `open_mapping`, `insert_mappings`, `terminal_mappings`, terminal-window mappings, and the `TermOpen` pattern, including `term://*toggleterm#*` for ToggleTerm-only mappings.
- [toggleterm.nvim config source](https://github.com/akinsho/toggleterm.nvim/blob/main/lua/toggleterm/config.lua) — Shows option type annotations and default values: `insert_mappings = true`, `terminal_mappings = true`, `start_in_insert = true`.

### Related Specs

- `.trellis/spec/frontend/component-guidelines.md:15` — `lua/plugins/toggleterm.lua` configures terminal split/float behavior, highlights, and terminal-mode mappings.
- `.trellis/spec/frontend/hook-guidelines.md:16` — terminal buffer mappings are installed via `TermOpen` in `lua/plugins/toggleterm.lua`.
- `.trellis/spec/frontend/hook-guidelines.md:69` — `_G.set_terminal_keymaps()` is a named global because it is referenced from a Vim command-string autocmd.
- `.trellis/spec/frontend/quality-guidelines.md:28-30` — keep plugin-owned keymaps with the plugin spec and preserve mode-specific keymaps; terminal-mode mappings use `vim.keymap.set('t', ...)` in `lua/plugins/toggleterm.lua`.
- `.trellis/spec/frontend/state-management.md:14` — terminal-local keymaps are buffer/window/filetype-local state in `lua/plugins/toggleterm.lua`.

## Caveats / Not Found

- ToggleTerm documentation does not discuss `coder/claudecode.nvim` specifically; the mapping to Claude behavior comes from the local repo's broad `TermOpen term://*` autocmd and prior Claude research.
- The external README example includes both a broad `term://*` autocmd and a comment documenting the narrower `term://*toggleterm#*` pattern. It does not state that one is universally preferred; it frames the narrower pattern as the choice "if you only want these mappings for toggle term".
- No ToggleTerm-specific option was found that scopes the custom `_G.set_terminal_keymaps()` function; scoping is controlled by the Neovim autocmd pattern used by the local config.
- `open_mapping` controls toggling ToggleTerm itself and, by default, can apply in insert/terminal modes through `insert_mappings` and `terminal_mappings`; this is separate from the custom terminal-window mappings installed by `_G.set_terminal_keymaps()`.
