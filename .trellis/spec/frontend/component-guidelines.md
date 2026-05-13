# Component Guidelines

> Plugin UI and editor interaction patterns for this Neovim configuration.

---

## Overview

There are no React/Vue/web components in this repository. The closest equivalent is plugin UI configuration: lazy.nvim plugin specs that define UI behavior, keymaps, dashboard sections, windows, borders, highlights, and statusline/bufferline options.

Existing component-like examples:

- `lua/plugins/snacks.lua` configures dashboard sections, picker, notifier, and LSP progress notifications.
- `lua/plugins/blink.lua` configures completion menu columns, borders, documentation windows, and signature help.
- `lua/plugins/toggleterm.lua` configures terminal split/float behavior, highlights, and terminal-mode mappings.
- `lua/plugins/bufferline.lua` configures tabline appearance and buffer click behavior.

---

## Component Structure

Use the existing lazy.nvim spec shape:

```lua
local opts = {
  -- plugin UI/options here
}

return {
  "plugin/name.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>x", "<cmd>Command<CR>", desc = "Action" },
  },
  opts = opts,
}
```

For plugins that need setup logic, use `config = function() ... end` as in `lua/plugins/toggleterm.lua` and `lua/plugins/bufferline.lua`. For plugins that can be configured declaratively, prefer `opts = { ... }` as in `lua/plugins/lualine.lua`, `lua/plugins/nvimtree.lua`, and `lua/plugins/blink.lua`.

---

## Props Conventions

Plugin options are the "props" in this repo.

- Name the table `opts` when the file passes it directly to lazy.nvim (`lua/plugins/blink.lua`, `lua/plugins/whichkey.lua`).
- Name the table `default` when it represents a local default config passed during `setup(...)`, as in `lua/plugins/treesitter.lua` and `lua/plugins/bufferline.lua`.
- Keep option tables close to the plugin spec unless they are reused elsewhere. Current files define options locally rather than exporting shared UI config.

---

## Styling Patterns

Styling is plugin-specific and uses Neovim options/highlights:

- Borders use simple strings such as `"single"` in `lua/plugins/blink.lua` and `lua/plugins/toggleterm.lua`; LSP float borders use `"rounded"` in `lua/plugins/lspconfig.lua`.
- Statusline theme is `gruvbox-material` in `lua/plugins/lualine.lua`, matching lazy.nvim install colorscheme in `lua/config/lazy.lua`.
- Terminal highlights are set explicitly with `vim.cmd([[ hi ... ]])` in `lua/plugins/toggleterm.lua`.
- Neovide GUI styling is isolated in `lua/config/neovide.lua` (`JetBrainsMono Nerd Font Mono:h12`, animations disabled).

---

## Accessibility

This is an editor configuration, so accessibility means discoverable, non-surprising interactions:

- Add `desc` to lazy.nvim key entries so which-key and lazy.nvim can display them. Examples exist throughout `lua/plugins/snacks.lua`, `lua/plugins/bufferline.lua`, and `lua/plugins/overseer.lua`.
- Group related leader mappings with a group entry before child mappings, for example `{ "<leader>b", group = "Buffer" }` in `lua/plugins/bufferline.lua`.
- Keep VS Code mappings in `lua/config/vscode.lua` aligned with normal Neovim concepts where possible (`ga`, `gd`, `gf`, `gr`, `gj`, `gk`, `<leader>fm`, `<leader>e`).

---

## Common Mistakes

- Do not create web component folders (`components/`, `pages/`, `hooks/`) for this repo.
- Do not put plugin UI options in `lua/core/mappings.lua`; plugin-owned UI belongs in `lua/plugins/<plugin>.lua`.
- Do not add a keymap without a `desc` when using lazy.nvim `keys`, unless following an existing no-desc pattern in the same file.
- Do not mix VS Code-only APIs (`VSCodeNotify`, `require('vscode')`) into normal plugin specs.
