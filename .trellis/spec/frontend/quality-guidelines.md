# Quality Guidelines

> Code quality standards for editor-facing UI, keymaps, and plugin configuration.

---

## Overview

Frontend quality in this repository means keeping the editor interaction surface consistent, discoverable, and safe across normal Neovim, VS Code Neovim, Neovide, Windows, and WSL.

There is no browser accessibility suite, frontend linter, or TypeScript check. Review UI changes by checking keymap consistency, lazy.nvim spec shape, startup behavior, and environment guards.

---

## Forbidden Patterns

- Do not define the same keymap in multiple normal-Neovim plugin/core files without a deliberate reason. Check `lua/core/mappings.lua`, `lua/plugins/lspconfig.lua`, `lua/plugins/snacks.lua`, and the relevant plugin file first.
- Do not put VS Code-only mappings or `VSCodeNotify` calls outside `lua/config/vscode.lua`.
- Do not add plugin keymaps without descriptions in lazy.nvim `keys` arrays when the surrounding file uses `desc`.
- Do not introduce web frontend tooling or directories (`src/components`, `hooks`, CSS frameworks) for this Neovim config.
- Do not make UI plugins eager (`lazy = false`) unless there is an existing startup need like `lua/plugins/snacks.lua`.

---

## Required Patterns

- Group leader mappings before child mappings, following examples such as `{ "<leader>f", group = "File" }` in `lua/plugins/snacks.lua` and `{ "<leader>b", group = "Buffer" }` in `lua/plugins/bufferline.lua`.
- Keep plugin-owned keymaps with the plugin spec. For example, NvimTree owns `<leader>e` in `lua/plugins/nvimtree.lua`, ToggleTerm owns `<leader>t...` in `lua/plugins/toggleterm.lua`, and Conform owns `<leader>fm` in `lua/plugins/conform.lua`.
- Keep related UI option tables local to the plugin file and pass them through `opts` or `setup(...)` consistently.
- Preserve mode-specific keymaps. Terminal-mode mappings use `vim.keymap.set('t', ...)` in `lua/plugins/toggleterm.lua`; visual clipboard mappings use `map("v", ...)` in `lua/core/mappings.lua` and `vim.keymap.set({ "v" }, ...)` in `lua/config/vscode.lua`.

---

## Testing Requirements

No automated UI tests exist. For UI/config changes:

1. Run a headless startup check when Neovim is available:

   ```powershell
   nvim --headless "+luafile init.lua" "+qa"
   ```

2. Manually inspect keymap conflicts in changed files.
3. For VS Code mapping changes, ensure the code remains isolated to `lua/config/vscode.lua`.
4. For terminal/shell changes, review Windows guards in `lua/plugins/toggleterm.lua`.

---

## Code Review Checklist

- Keymaps are discoverable through `desc` and existing leader groups.
- Plugin specs still return valid lazy.nvim tables.
- UI settings stay with the responsible plugin or environment config.
- Normal Neovim, VS Code Neovim, Neovide, Windows, and WSL paths remain guarded.
- New notifications are concise and do not spam high-frequency events.
- No generated plugin/runtime state or local machine paths are committed.
