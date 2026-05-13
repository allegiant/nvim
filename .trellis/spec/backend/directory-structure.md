# Directory Structure

> Core Lua/config/runtime organization for this Neovim configuration.

---

## Overview

This repository is a Neovim configuration, not a backend service. Treat the Trellis "backend" layer as the core runtime configuration: startup flow, shared helpers, editor options, autocommands, plugin bootstrap, LSP setup, and task templates.

Startup is intentionally small and ordered in `init.lua`: VS Code mode short-circuits to `lua/config/vscode.lua`; normal Neovim loads `lua/core/options.lua`, `lua/core/autocmds.lua`, `lua/core/mappings.lua`, `lua/config/lazy.lua`, then `lspconfig`.

---

## Directory Layout

```text
init.lua                         # entry point; dispatches VS Code / Neovide / normal Neovim paths
lua/core/options.lua             # global vim.opt and vim.g editor defaults
lua/core/autocmds.lua            # global autocmds and filetype-local indentation
lua/core/mappings.lua            # base keymaps that are not owned by a plugin
lua/core/utils.lua               # small reusable Lua helpers and notify wrappers
lua/config/lazy.lua              # lazy.nvim bootstrap and plugin import
lua/config/neovide.lua           # Neovide-only GUI settings
lua/config/vscode.lua            # vscode-neovim integration path
lua/lsp/*.lua                    # one LSP server module per language/server family
lua/plugins/*.lua                # one lazy.nvim plugin spec per plugin or tightly-coupled plugin group
lua/overseer/template/user/*.lua # user task templates consumed by overseer.nvim
.vsnip/*.json                    # snippet files
lazy-lock.json                   # lazy.nvim plugin lockfile
.luarc.json                      # lua-language-server workspace diagnostics globals
```

---

## Module Organization

- Keep startup routing in `init.lua`; do not add plugin setup or feature logic there. Existing examples: `require "core.options"`, `require "config.lazy"`, and the `vim.g.vscode` branch.
- Put globally shared Neovim behavior in `lua/core/`:
  - options in `lua/core/options.lua`
  - editor-wide autocommands in `lua/core/autocmds.lua`
  - generic keymaps in `lua/core/mappings.lua`
  - reusable helper functions in `lua/core/utils.lua`
- Put environment-specific configuration in `lua/config/`, as shown by `lua/config/vscode.lua` and `lua/config/neovide.lua`.
- Add plugins under `lua/plugins/` as lazy.nvim specs. `lua/config/lazy.lua` imports the whole folder with `{ import = "plugins" }`; avoid manually requiring individual plugin spec files from startup.
- Add or modify LSP server setup in `lua/lsp/<server>.lua`, then call `<module>.setup()` from `lua/plugins/lspconfig.lua`. Existing modules use this pattern in `lua/lsp/lua_ls.lua`, `lua/lsp/jsonls.lua`, `lua/lsp/pylsp.lua`, and `lua/lsp/vue_ls.lua`.

---

## Naming Conventions

- Lua modules use lowercase or plugin/server names that match their purpose: `lua/plugins/bufferline.lua`, `lua/plugins/toggleterm.lua`, `lua/lsp/jsonls.lua`.
- LSP modules return a table `M` with `M.setup = function() ... end`.
- Lazy plugin files return a plugin spec table directly. A file may return an array when configuring related plugins together, as in `lua/plugins/treesitter.lua` and `lua/plugins/blink.lua`.
- Prefer local aliases for frequently used Neovim globals inside core files (`local opt = vim.opt`, `local autocmd = vim.api.nvim_create_autocmd`) when the file already follows that style.

---

## Examples

### Startup routing from `init.lua`

```lua
if vim.g.vscode then
  require("config.vscode")
else
  if vim.g.neovide then
    require("config.neovide")
  end
  require "core.options"
  require "core.autocmds"
  require "core.mappings"
  require "config.lazy"
  require "lspconfig"
end
```

### LSP module shape from `lua/lsp/jsonls.lua`

```lua
local M = {}

M.setup = function()
  local present, mason_registry = pcall(require, "mason-registry")
  if not present then
    return
  end

  local installed = mason_registry.is_installed("json-lsp")
  if not installed then
    return
  end

  vim.lsp.config('jsonls', opts)
  vim.lsp.enable('jsonls')
end

return M
```
