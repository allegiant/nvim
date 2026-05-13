# Research: claude-code.nvim Esc / terminal behavior

- **Query**: Research the plugin documentation and relevant behavior for https://github.com/greggh/claude-code.nvim, specifically how it manages terminal buffers, keymaps, Esc behavior, and recommended configuration to avoid Esc interrupting Claude while still allowing returning to normal mode in Neovim. Include concrete config option names and examples if documented, plus how they map to this Neovim config repository.
- **Scope**: mixed
- **Date**: 2026-05-13

## Findings

### Files Found

| File Path | Description |
|---|---|
| `lua/plugins/claudecode.lua` | Local Claude Code plugin declaration. Uses `coder/claudecode.nvim`, not `greggh/claude-code.nvim`. Defines Lazy keymaps for ClaudeCode commands but currently uses `config = true` with no terminal-specific options. |
| `lua/plugins/toggleterm.lua` | Local terminal-wide keymaps registered on every `TermOpen term://*`; maps terminal-mode `<esc>` and `jk` to Neovim terminal normal-mode escape sequence `<C-\\><C-n>`. This applies to Claude terminal buffers if they are regular Neovim terminal buffers. |
| `.trellis/spec/guides/index.md` | Related general Trellis guide index; no Claude Code plugin-specific spec found. |
| `.trellis/spec/frontend/index.md` | Related frontend spec index; no Claude Code plugin-specific spec found. |
| `.trellis/spec/backend/index.md` | Related backend spec index; no Claude Code plugin-specific spec found. |

### Code Patterns

Local config repository:

- `lua/plugins/claudecode.lua:1-24` declares:

```lua
return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  config = true,
  keys = {
    { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
    { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
  },
}
```

- This repository is not currently using the `greggh/claude-code.nvim` package name (`greggh/claude-code.nvim`) or its documented `require("claude-code").setup({...})` setup shape. The local plugin is `coder/claudecode.nvim`, whose README documents a different `opts = { terminal = { ... } }` shape.
- `lua/plugins/toggleterm.lua:19-27` defines terminal-mode mappings for every `TermOpen` terminal buffer:

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

- `lua/plugins/toggleterm.lua:75` installs the keymaps globally for terminals:

```lua
vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
```

- Mapping implication: if Claude is running inside a Neovim terminal buffer, pressing `<Esc>` is intercepted by Neovim and converted to `<C-\\><C-n>`. This should return Neovim from terminal insert mode to terminal normal mode instead of sending an Esc byte to the Claude process. If a Claude UI uses Esc internally, this mapping can prevent Esc from reaching Claude.

Upstream `greggh/claude-code.nvim` documentation and source behavior:

- README/config docs show terminal window settings:
  - `window.split_ratio = 0.3` — terminal size as a fraction of screen.
  - `window.position = "botright"` — terminal split placement; docs mention values such as `"botright"`, `"topleft"`, `"vertical"`, `"vsplit"`, and current README also mentions `"float"`.
  - `window.enter_insert = true` — whether to enter insert mode when opening Claude Code.
  - `window.start_in_normal_mode = false` — documented in `doc/claude-code.txt` and source config, starts terminal in normal mode instead of insert mode.
- Upstream `greggh/claude-code.nvim` defaults from `lua/claude-code/config.lua`:

```lua
window = {
  split_ratio = 0.3,
  height_ratio = 0.3, -- deprecated alias
  position = 'botright',
  enter_insert = true,
  start_in_normal_mode = false,
},
keymaps = {
  toggle = {
    normal = '<C-,>',
    terminal = '<C-,>',
    variants = {
      continue = '<leader>cC',
      verbose = '<leader>cV',
    },
  },
  window_navigation = true,
  scrolling = true,
}
```

- Upstream keymap registration in `lua/claude-code/keymaps.lua`:
  - `keymaps.toggle.normal` registers a normal-mode mapping to `:ClaudeCode`.
  - `keymaps.toggle.terminal` registers a terminal-mode mapping using `[[<C-\\><C-n>:ClaudeCode<CR>]]` so terminal mode exits to normal mode before toggling.
  - `keymaps.window_navigation = true` enables Claude-terminal-local `<C-h>`, `<C-j>`, `<C-k>`, `<C-l>` mappings in both terminal and normal modes.
  - `keymaps.scrolling = true` enables `<C-f>` and `<C-b>` mappings in terminal mode, implemented as `[[<C-\\><C-n><C-f>i]]` and `[[<C-\\><C-n><C-b>i]]`.
- Upstream terminal navigation docs list, inside the Claude Code terminal:
  - `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` move between windows.
  - `<C-f>` / `<C-b>` scroll a full page.
  - After scrolling, docs state that pressing `i` may be needed to re-enter insert mode to keep typing to Claude.
- Upstream terminal buffer management in `lua/claude-code/terminal.lua`:
  - Maintains `instances = {}` keyed by project/git context.
  - Uses `vim.fn.termopen(cmd)` to launch the Claude command in a terminal buffer.
  - Stores created buffers in `claude_code.claude_code.instances[instance_id]`.
  - `git.multi_instance = true` is the documented default for one Claude instance per git root.
  - `force_insert_mode(claude_code, config)` checks whether the current buffer is one of the Claude terminal buffers, then respects `config.window.start_in_normal_mode`; if normal-mode start is enabled, it does not force insert mode.

Esc behavior specifically:

- The `greggh/claude-code.nvim` docs and source excerpts found do not document an explicit plugin-level `<Esc>` option or `<Esc>` keymap.
- The upstream plugin relies on standard Neovim terminal-mode escape behavior (`<C-\\><C-n>`) in its own terminal keymaps. This is visible in the terminal toggle and navigation mappings.
- For standard Neovim terminal buffers, `<C-\\><C-n>` is the canonical way to leave terminal insert mode and return to terminal normal mode without sending an interrupt/control character to the running process.
- Relevant external `coder/claudecode.nvim` issue #29 states the same standard Neovim behavior: `ctrl+\` then `ctrl+n` puts the terminal back into normal mode; with the Snacks provider, Esc may work depending on user Esc timeout settings.

Concrete documented `greggh/claude-code.nvim` configuration examples:

```lua
require("claude-code").setup({
  window = {
    split_ratio = 0.3,
    position = "botright",
    enter_insert = true,
    start_in_normal_mode = false,
  },
  keymaps = {
    toggle = {
      normal = "<C-,>",
      terminal = "<C-,>",
      variants = {
        continue = "<leader>cC",
        verbose = "<leader>cV",
      },
    },
    window_navigation = true,
    scrolling = true,
  },
})
```

Documented option meanings relevant to Esc / terminal mode:

| Option | Documented meaning | Relation to Esc / mode behavior |
|---|---|---|
| `window.enter_insert` | Enter insert mode when opening Claude Code. | If `true`, the Claude terminal starts ready for input. |
| `window.start_in_normal_mode` | Start terminal in normal mode instead of insert mode. | If `true`, upstream `force_insert_mode` respects normal mode and avoids forcing insert mode. |
| `keymaps.toggle.terminal` | Terminal-mode toggle key, default `<C-,>`, or `false` to disable. | Implemented with `<C-\\><C-n>:ClaudeCode<CR>` so it leaves terminal insert mode before running the command. |
| `keymaps.window_navigation` | Enable `<C-h/j/k/l>` window navigation in Claude terminal. | Provides documented movement without using Esc. |
| `keymaps.scrolling` | Enable `<C-f/b>` page scrolling in Claude terminal. | Uses terminal-normal transition internally; docs mention pressing `i` afterward if needed. |

Mapping these findings to this repository:

- If the intended target is truly `greggh/claude-code.nvim`, the local plugin declaration would not match the upstream documented package or setup module. The documented config shape is `require("claude-code").setup({...})` with `window` and `keymaps` tables.
- The current repository uses `coder/claudecode.nvim`; its README documents `opts = { terminal = { split_side, split_width_percentage, provider, auto_close, snacks_win_opts, provider_opts } }`, not `window = { split_ratio, position, enter_insert, start_in_normal_mode }`.
- The local repository already has a global terminal `<Esc>` mapping in `toggleterm.lua`; this is likely the current mechanism for returning from terminal insert mode to Neovim normal mode in Claude terminal buffers.
- The local global terminal mappings overlap with upstream `greggh` Claude terminal mappings for `<C-h/j/k/l>` if the upstream plugin is used, because both define terminal navigation keys. Upstream `greggh` sets Claude-buffer-local mappings; local `toggleterm.lua` sets mappings on every terminal buffer.

### External References

- [greggh/claude-code.nvim README](https://github.com/greggh/claude-code.nvim) — documents default setup, terminal window options, keymaps, navigation, and scrolling note.
- [greggh/claude-code.nvim doc/claude-code.txt](https://github.com/greggh/claude-code.nvim/blob/main/doc/claude-code.txt) — documents `window.start_in_normal_mode`, command list, and terminal navigation keys.
- [greggh/claude-code.nvim lua/claude-code/config.lua](https://github.com/greggh/claude-code.nvim/blob/main/lua/claude-code/config.lua) — source of default option names and validation for `window.start_in_normal_mode`, `keymaps.window_navigation`, and `keymaps.scrolling`.
- [greggh/claude-code.nvim lua/claude-code/keymaps.lua](https://github.com/greggh/claude-code.nvim/blob/main/lua/claude-code/keymaps.lua) — source for terminal-mode mappings using `<C-\\><C-n>`.
- [greggh/claude-code.nvim lua/claude-code/terminal.lua](https://github.com/greggh/claude-code.nvim/blob/main/lua/claude-code/terminal.lua) — source for terminal buffer creation with `termopen`, instance tracking, and `force_insert_mode` behavior.
- [coder/claudecode.nvim README](https://github.com/coder/claudecode.nvim) — relevant because this local repository currently uses `coder/claudecode.nvim`; documents `opts.terminal` config shape.
- [coder/claudecode.nvim issue #29](https://github.com/coder/claudecode.nvim/issues/29) — discusses leaving terminal mode using `<C-\\><C-n>` and mentions Snacks/Esc behavior depends on user Esc timeout settings.

### Related Specs

- `.trellis/spec/guides/index.md` — general guide index only; no plugin-specific guidance found.
- `.trellis/spec/frontend/index.md` — package index only; no plugin-specific guidance found.
- `.trellis/spec/backend/index.md` — package index only; no plugin-specific guidance found.

## Caveats / Not Found

- No explicit `greggh/claude-code.nvim` plugin-level option for mapping `<Esc>` was found in README/doc/config/keymap source excerpts.
- The user query names `greggh/claude-code.nvim`, but the local file `lua/plugins/claudecode.lua` uses `coder/claudecode.nvim`. Configuration examples for `greggh` do not directly apply to `coder` without adapting to the different plugin API.
- The exact behavior of Esc inside the currently configured `coder/claudecode.nvim` instance depends on which terminal provider is selected (`auto`, `snacks`, `native`, etc.) and on the global `TermOpen` mapping in `lua/plugins/toggleterm.lua`.
- External search results were used for upstream docs/source. Full repository checkout was not performed.
