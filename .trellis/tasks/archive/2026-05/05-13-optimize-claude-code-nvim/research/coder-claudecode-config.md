# Research: coder/claudecode.nvim configuration and terminal Esc behavior

- **Query**: Research the current documentation/source for https://github.com/coder/claudecode.nvim specifically. Focus on supported setup/opts shape, terminal provider options, whether there are keymap or terminal Esc options, how terminal buffers can be identified, and recommended way to avoid Esc interrupting Claude while retaining a Neovim normal-mode escape. Include concrete option names and config snippets if documented.
- **Scope**: mixed
- **Date**: 2026-05-13

## Findings

### Files Found

| File Path | Description |
|---|---|
| `lua/plugins/claudecode.lua` | Local Lazy plugin declaration for `coder/claudecode.nvim`; uses `dependencies = { "folke/snacks.nvim" }`, `config = true`, and command keymaps only. |
| `https://github.com/coder/claudecode.nvim/blob/main/README.md` | Upstream README documenting Lazy setup, advanced `opts`, `terminal` options, Snacks floating window key bindings, and terminal providers. |
| `https://github.com/coder/claudecode.nvim/blob/main/lua/claudecode/config.lua` | Upstream config defaults and validation; top-level config shape. |
| `https://github.com/coder/claudecode.nvim/blob/main/lua/claudecode/init.lua` | Upstream `setup(opts)` implementation and user command definitions. |
| `https://github.com/coder/claudecode.nvim/blob/main/lua/claudecode/terminal.lua` | Upstream terminal module defaults, provider selection, terminal config validation, and `get_active_terminal_bufnr()`. |
| `https://github.com/coder/claudecode.nvim/blob/main/lua/claudecode/terminal/native.lua` | Upstream native terminal provider; creates the Neovim terminal buffer and tracks `bufnr`. |
| `https://github.com/coder/claudecode.nvim/blob/main/lua/claudecode/terminal/snacks.lua` | Upstream Snacks terminal provider; passes `snacks_win_opts` into `Snacks.terminal.open()` and tracks `terminal.buf`. |
| `https://github.com/coder/claudecode.nvim/blob/main/lua/claudecode/types.lua` | Upstream type annotations for terminal provider names, provider interface, and config fields. |
| `https://github.com/coder/claudecode.nvim/issues/77` | Upstream open issue about `<Esc>` cancelling Claude Code input and maintainer guidance on terminal-mode remapping. |

### Code Patterns

#### Local configuration

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
    { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
  },
}
```

- There is no local `opts = { ... }` table yet, so upstream defaults apply.

#### Supported setup / opts shape

- README advanced Lazy shape uses `opts = { ... }` under the plugin spec, not a `window = { ... }` table. Documented top-level options include:
  - `port_range = { min = 10000, max = 65535 }`
  - `auto_start = true`
  - `log_level = "info"`
  - `terminal_cmd = nil`
  - `focus_after_send = false`
  - `track_selection = true`
  - `visual_demotion_delay_ms = 50`
  - `terminal = { ... }`
  - `diff_opts = { ... }`
- Source confirms `require("claudecode").setup(opts)` applies `opts` via `config.apply(opts)` and then calls `terminal_module.setup(opts.terminal, M.state.config.terminal_cmd, M.state.config.env)` (`init.lua:319-360`).
- README also documents direct setup examples:

```lua
require("claudecode").setup({
  terminal = {
    cwd = vim.fn.expand("~/projects/my-app"),
  },
})
```

#### Terminal options and provider options

README `opts.terminal` documented shape:

```lua
opts = {
  terminal_cmd = nil, -- Custom terminal command (default: "claude")
  terminal = {
    split_side = "right", -- "left" or "right"
    split_width_percentage = 0.30,
    provider = "auto", -- "auto", "snacks", "native", "external", "none", or custom provider table
    auto_close = true,
    snacks_win_opts = {}, -- Opts to pass to `Snacks.terminal.open()`
    provider_opts = {
      external_terminal_cmd = nil,
    },
  },
}
```

Source default fields in `terminal.lua` additionally include:

```lua
local defaults = {
  split_side = "right",
  split_width_percentage = 0.30,
  provider = "auto",
  show_native_term_exit_tip = true,
  terminal_cmd = nil,
  provider_opts = { external_terminal_cmd = nil },
  auto_close = true,
  env = {},
  snacks_win_opts = {},
  cwd = nil,
  git_repo_cwd = false,
  cwd_provider = nil,
}
```

Provider selection in `terminal.lua`:

- `provider = "auto"`: try Snacks first, then fall back to native (`terminal.lua:130-136`).
- `provider = "snacks"`: use Snacks if available, otherwise warn and fall back to native (`terminal.lua:137-143`).
- `provider = "native"`: use native Neovim terminal (`terminal.lua:166-168`).
- `provider = "external"`: requires `terminal.provider_opts.external_terminal_cmd` to be a function or a non-empty string containing `%s`; otherwise falls back to native (`terminal.lua:144-164`).
- `provider = "none"`: no-op provider, no windows/buffers are created (`terminal.lua:169-175`; README notes no windows/buffers are created and `:ClaudeCode` will not open anything).
- `provider` can also be a custom provider table.

External provider documented snippets:

```lua
opts = {
  terminal = {
    provider = "external",
    provider_opts = {
      external_terminal_cmd = "alacritty -e %s",
      -- Or: "alacritty --working-directory %s -e %s"
    },
  },
}
```

```lua
opts = {
  terminal = {
    provider = "external",
    provider_opts = {
      external_terminal_cmd = function(cmd, env)
        return "alacritty -e " .. cmd
      end,
    },
  },
}
```

Custom provider documented required functions:

```lua
require("claudecode").setup({
  terminal = {
    provider = {
      setup = function(config) end,
      open = function(cmd_string, env_table, effective_config, focus) end,
      close = function() end,
      simple_toggle = function(cmd_string, env_table, effective_config) end,
      focus_toggle = function(cmd_string, env_table, effective_config) end,
      get_active_bufnr = function() return 123 end,
      is_available = function() return true end,
    },
  },
})
```

#### Keymap and terminal Esc options

- README documents Lazy `keys = { ... }` for Neovim command mappings such as `:ClaudeCode`, `:ClaudeCodeFocus`, `:ClaudeCodeSend`, and diff accept/deny. These are Lazy.nvim keymaps, not plugin-internal terminal input keymaps.
- README documents `terminal.snacks_win_opts.keys` as the way to pass Snacks window key bindings to `Snacks.terminal.open()`.
- Snacks provider source merges defaults with `config.snacks_win_opts` (`snacks.lua:57-75`). Default Snacks terminal key is only `claude_new_line = { "<S-CR>", ..., mode = "t", desc = "New line" }` (`snacks.lua:62-74`).
- README examples show terminal-mode hide bindings in `snacks_win_opts.keys`, including:

```lua
snacks_win_opts = {
  position = "float",
  width = 0.6,
  height = 0.6,
  border = "double",
  backdrop = 80,
  keys = {
    claude_hide = { "<Esc>", function(self) self:hide() end, mode = "t", desc = "Hide" },
    claude_close = { "q", "close", mode = "n", desc = "Close" },
  },
}
```

and:

```lua
snacks_win_opts = {
  keys = {
    claude_hide_ctrl = { "<C-,>", function(self) self:hide() end, mode = "t", desc = "Hide (Ctrl+,)" },
    claude_hide_alt = { "<M-,>", function(self) self:hide() end, mode = "t", desc = "Hide (Alt+,)" },
    claude_hide_esc = { "<C-\\><C-n>", function(self) self:hide() end, mode = "t", desc = "Hide (Ctrl+\\)" },
  },
}
```

- No documented top-level `cancel_key`, `esc_key`, `terminal_esc`, `keymaps`, or equivalent option was found in README or config source.
- Issue #77 proposes `opts = { cancel_key = "<C-c>" }`, but it is an open feature request, not a documented/implemented option.
- Maintainer comment in issue #77 states they are not aware of a way for the plugin to change Claude Code's `<Esc>` keybinding because the plugin launches Claude Code in a Neovim terminal buffer. They point to Neovim terminal input docs and say remapping terminal-mode keys should be done in user config. The quoted Neovim example is:

```vim
:tnoremap <Esc> <C-\><C-n>
```

#### Terminal buffer identification

- Public terminal module helper: `require("claudecode.terminal").get_active_terminal_bufnr()` returns `get_provider().get_active_bufnr()` (`terminal.lua:553-557`).
- Custom providers are required to implement `get_active_bufnr()` (`terminal.lua:59-67`; README custom provider section lines 588-590).
- Native provider:
  - On successful `termopen`, it stores `bufnr = vim.api.nvim_get_current_buf()` and sets `vim.bo[bufnr].bufhidden = "hide"` (`native.lua:89-135`).
  - Native buffer has `buftype=terminal` from `termopen` (`native.lua:135`).
  - `get_active_bufnr()` returns `bufnr` only when the tracked buffer/window state is valid (`native.lua:425-430`).
  - Recovery logic scans all buffers where `buftype == "terminal"` and buffer name matches `"claude"`, then checks visible windows (`native.lua:250-270`).
- Snacks provider:
  - Stores the returned Snacks terminal instance in local `terminal` (`snacks.lua:130-134`).
  - `get_active_bufnr()` returns `terminal.buf` when valid (`snacks.lua:252-260`).
- External and none providers return no Neovim terminal buffer:
  - External provider comment: "External terminals don't have associated Neovim buffers" (`external.lua:183-188`).
  - None provider `get_active_bufnr()` always returns nil (`none.lua:56-58`).

#### Avoiding Esc interrupting Claude while retaining a Neovim normal-mode escape

Documented/upstream guidance found:

1. Maintainer guidance in issue #77: remap terminal-mode keys in Neovim config because the plugin is running Claude inside a terminal buffer.
2. The concrete Neovim mapping example from the maintainer comment is:

```vim
:tnoremap <Esc> <C-\><C-n>
```

3. For Snacks floating windows, README documents using `terminal.snacks_win_opts.keys` for terminal-mode key bindings. The README uses this to hide the terminal on `<Esc>` or `<C-\\><C-n>`, not specifically to enter terminal normal mode.
4. Native terminal provider itself notifies: `Native terminal opened. Press Ctrl-\ Ctrl-N to return to Normal mode.` (`native.lua:146-147`).

A buffer-aware Lua mapping can use the plugin's public terminal buffer helper to avoid mapping `<Esc>` in every terminal buffer:

```lua
vim.keymap.set("t", "<Esc>", function()
  local ok, terminal = pcall(require, "claudecode.terminal")
  local claude_buf = ok and terminal.get_active_terminal_bufnr and terminal.get_active_terminal_bufnr()
  if claude_buf == vim.api.nvim_get_current_buf() then
    return [[<C-\><C-n>]]
  end
  return [[<Esc>]]
end, { expr = true, desc = "Exit Claude terminal mode without sending Esc" })
```

This snippet is derived from documented Neovim terminal remapping plus the plugin's documented/source-exposed buffer helper; it is not a README-provided snippet.

### External References

- [coder/claudecode.nvim README](https://github.com/coder/claudecode.nvim) — documents Lazy setup, `opts.terminal`, providers, `snacks_win_opts.keys`, custom provider interface, and troubleshooting.
- [coder/claudecode.nvim terminal.lua](https://github.com/coder/claudecode.nvim/blob/main/lua/claudecode/terminal.lua) — source for terminal defaults, provider names, provider fallback behavior, config validation, and `get_active_terminal_bufnr()`.
- [coder/claudecode.nvim native provider](https://github.com/coder/claudecode.nvim/blob/main/lua/claudecode/terminal/native.lua) — source for native terminal buffer creation and native buffer recovery by `buftype=terminal` plus name matching `claude`.
- [coder/claudecode.nvim Snacks provider](https://github.com/coder/claudecode.nvim/blob/main/lua/claudecode/terminal/snacks.lua) — source for `snacks_win_opts` merge and `terminal.buf` tracking.
- [Issue #77: Make chat input cancel key configurable instead of forcing `<Esc>` to cancel](https://github.com/coder/claudecode.nvim/issues/77) — open issue confirming no implemented `cancel_key`; maintainer recommends terminal-mode remapping in user config and cites `:tnoremap <Esc> <C-\><C-n>`.
- [Neovim terminal input docs](https://neovim.io/doc/user/terminal.html#terminal-input) — referenced by upstream maintainer for terminal-mode key remapping behavior.

### Related Specs

- No task-specific implementation spec found under `.trellis/spec/` for `claudecode.nvim`.
- General guides exist under `.trellis/spec/guides/`, but they do not define plugin-specific `claudecode.nvim` configuration contracts.

## Caveats / Not Found

- No documented `cancel_key`, `esc_key`, or `terminal Esc` plugin option was found in upstream README or current source. The only `cancel_key` shape found is a proposed option in open issue #77.
- README contains a Snacks example binding `<Esc>` to `self:hide()`; that hides the Snacks window, not a normal-mode escape.
- Global `tnoremap <Esc> <C-\><C-n>` is the maintainer-cited Neovim approach, but it applies to all terminal buffers unless made buffer-aware.
- For `provider = "external"` and `provider = "none"`, there is no Neovim terminal buffer to identify or buffer-local-map.
