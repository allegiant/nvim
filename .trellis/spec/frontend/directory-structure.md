# Directory Structure

> UI/editor interaction and plugin-facing organization for this Neovim configuration.

---

## Overview

This repository has no web frontend. Treat the Trellis "frontend" layer as the editor-facing surface: keymaps, plugin UI behavior, completion UI, file explorer, statusline, bufferline, terminal windows, picker commands, VS Code integration, and GUI-specific Neovide settings.

The UI surface is split by ownership:

- base editor mappings in `lua/core/mappings.lua`
- plugin-owned mappings and UI options in `lua/plugins/*.lua`
- VS Code Neovim mappings in `lua/config/vscode.lua`
- Neovide GUI options in `lua/config/neovide.lua`

---

## Directory Layout

```text
lua/core/mappings.lua       # global non-plugin keymaps
lua/plugins/snacks.lua      # picker/dashboard/notifier UI and LSP navigation mappings
lua/plugins/nvimtree.lua    # file explorer UI and <leader>e mapping
lua/plugins/bufferline.lua  # buffer tabline UI and buffer navigation mappings
lua/plugins/lualine.lua     # statusline theme/options
lua/plugins/toggleterm.lua  # terminal UI, terminal-mode mappings, Windows shell options
lua/plugins/blink.lua       # completion, command-line completion, signature UI
lua/plugins/whichkey.lua    # which-key behavior and disabled presets
lua/plugins/conform.lua     # formatting command/keymap
lua/config/vscode.lua       # vscode-neovim keymap and command bridge
lua/config/neovide.lua      # Neovide font and animation settings
```

---

## Module Organization

- Put generic keymaps that do not depend on a plugin in `lua/core/mappings.lua`. Current examples: clipboard mappings, window navigation, window resize, split creation, and `:nohlsearch`.
- Put plugin-specific UI and keymaps in that plugin's spec file under `lua/plugins/`. Examples: file picker keys in `lua/plugins/snacks.lua`, file tree key in `lua/plugins/nvimtree.lua`, terminal keys in `lua/plugins/toggleterm.lua`.
- Keep VS Code integration separate in `lua/config/vscode.lua`; it uses `vim.fn.VSCodeNotify(...)` and `require('vscode').action(...)`, which are not valid assumptions for normal Neovim.
- Keep GUI-only Neovide settings in `lua/config/neovide.lua` and load them only through the `vim.g.neovide` branch in `init.lua`.

---

## Naming Conventions

- Leader groups are capitalized and defined through lazy.nvim `keys` entries: `File`, `Buffer`, `Terminal`, `Run Tasks`.
- Key descriptions are short user-facing labels, usually imperative or noun phrases: `Find Files`, `Format buffer`, `NvimTree Toggle`, `Git Status`.
- Existing navigation prefixes:
  - `<leader>f...` for picker/file actions in `lua/plugins/snacks.lua`.
  - `<leader>b...` for buffers in `lua/plugins/bufferline.lua`.
  - `<leader>t...` for terminals in `lua/plugins/toggleterm.lua`.
  - `<leader>r...` for Overseer tasks in `lua/plugins/overseer.lua`.
  - `g...` for LSP navigation/actions in `lua/plugins/lspconfig.lua`, `lua/plugins/snacks.lua`, and `lua/config/vscode.lua`.

---

## Examples

### Plugin-owned keymaps from `lua/plugins/snacks.lua`

```lua
keys = {
  { "<leader>f",  group = "File" },
  { "<leader>ff", "<cmd>lua Snacks.picker.files()<cr>", desc = "Find Files" },
  { "gf",         "<cmd>lua Snacks.picker.lsp_references()<CR>", nowait = true, desc = "References" },
}
```

### Base keymaps from `lua/core/mappings.lua`

```lua
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)
```
