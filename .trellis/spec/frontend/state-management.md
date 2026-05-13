# State Management

> Editor state, plugin state, and configuration state in this Neovim configuration.

---

## Overview

There is no frontend state library. State is managed through Neovim globals/options, plugin option tables, local Lua tables, lazy.nvim lockfile state, and plugin-owned runtime files.

Observed state categories:

- Global editor state: `vim.g` and `vim.opt` in `lua/core/options.lua`, `lua/config/lazy.lua`, and `lua/config/neovide.lua`.
- Buffer/window/filetype-local state: `vim.opt_local` in `lua/core/autocmds.lua`, terminal-local keymaps in `lua/plugins/toggleterm.lua`.
- Plugin configuration state: `opts`/`default` tables in `lua/plugins/*.lua`.
- Transient runtime state: local tables inside callbacks, for example `local progress = vim.defaulttable()` in `lua/plugins/snacks.lua`.
- Persisted plugin dependency state: `lazy-lock.json`.

---

## State Categories

### Global editor state

Use global state only for Neovim options that must apply editor-wide. Existing examples:

```lua
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
opt.termguicolors = true
opt.number = true
opt.relativenumber = true
```

### Environment-specific global state

Keep environment-specific globals isolated:

- WSL clipboard configuration is guarded by `if vim.fn.has('wsl') == 1 then ... end` in `lua/core/options.lua`.
- Windows shell settings are guarded by `if (is_win32 == 1) then ... end` in `lua/plugins/toggleterm.lua`.
- Neovide globals live in `lua/config/neovide.lua` and load only when `vim.g.neovide` is true.

### Plugin-local state

Prefer local tables inside plugin modules. `lua/plugins/snacks.lua` keeps LSP progress state local to `init = function()`:

```lua
local progress = vim.defaulttable()
vim.api.nvim_create_autocmd("LspProgress", {
  callback = function(ev)
    -- update progress[client.id]
  end,
})
```

---

## When to Use Global State

Use `vim.g` only when Neovim or a plugin expects a global variable, or when a value must be established before plugin loading. Existing required examples:

- `vim.g.mapleader` and `vim.g.maplocalleader` before lazy.nvim setup in `lua/config/lazy.lua`.
- distribution plugin disable flags in `lua/core/options.lua` (`vim_g.loaded_netrwPlugin = 1`, etc.).
- Neovide-specific globals in `lua/config/neovide.lua`.

Do not use globals for data that can stay local to one plugin spec or callback.

---

## Server State

Not applicable. There is no server state, cache invalidation, or remote data synchronization in this repository.

External tool state is handled by plugins and Mason. LSP modules check Mason package installation before enabling servers; they do not store server state in this repo.

---

## Common Mistakes

- Do not promote plugin-local tables to globals unless a Neovim command string or plugin API requires it.
- Do not duplicate `mapleader` setup in new places; it is already set before lazy.nvim and in VS Code mode.
- Do not store machine-specific runtime paths in committed files. Use `vim.fn.stdpath(...)`, `vim.fn.expand(...)`, or plugin defaults as existing code does.
- Do not hand-maintain plugin runtime state outside lazy.nvim/Mason conventions.
