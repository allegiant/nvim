# Hook Guidelines

> Autocommands, callbacks, and event-driven patterns in this Neovim configuration.

---

## Overview

There are no React hooks. The hook equivalents are Neovim autocommands, lazy.nvim load events, plugin callbacks, and keymap callback functions.

Observed hook/event locations:

- Global autocommands live in `lua/core/autocmds.lua`.
- Plugin load events live in plugin specs (`event = { "BufReadPre", "BufNewFile" }` in `lua/plugins/lspconfig.lua`, `event = { "BufWritePre" }` in `lua/plugins/conform.lua`, `event = 'VimEnter'` in `lua/plugins/bufferline.lua`).
- Plugin-specific autocommands can be declared inside plugin specs when they depend on the plugin, as in `lua/plugins/snacks.lua` for `LspProgress`.
- Terminal buffer mappings are installed via a `TermOpen` autocmd in `lua/plugins/toggleterm.lua`.

---

## Custom Hook Patterns

Use `vim.api.nvim_create_autocmd` for new Lua autocommands. Prefer callbacks for non-trivial logic and `command` only for short Vimscript-compatible commands.

Existing callback pattern from `lua/core/autocmds.lua`:

```lua
autocmd("FileType", {
  pattern = "lua",
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
  end,
})
```

Use augroups for hooks that must be uniquely replaceable or cleared:

```lua
autocmd({ 'VimLeavePre' }, {
  group = vim.api.nvim_create_augroup('fuck_shada_temp', { clear = true }),
  pattern = { '*' },
  callback = function()
    -- cleanup logic
  end,
  desc = "Delete empty temp ShaDa files"
})
```

When the hook is plugin-specific, keep it with the plugin. `lua/plugins/snacks.lua` defines its `LspProgress` autocmd inside `init = function()` because it uses Snacks notifier behavior.

---

## Data Fetching

No server data fetching exists. Event callbacks may read local runtime state through Neovim APIs:

- `vim.lsp.get_client_by_id(...)` and LSP progress event payloads in `lua/plugins/snacks.lua`.
- `vim.fn.globpath(...)`, `vim.fn.readfile(...)`, and `vim.fn.delete(...)` in `lua/core/autocmds.lua`.
- `vim.fn.executable(...)` in `lua/plugins/toggleterm.lua` to choose PowerShell executable.

Keep filesystem reads guarded and scoped to the event that needs them.

---

## Naming Conventions

- Use descriptive local variables for Neovim APIs at file top when repeated (`local autocmd = vim.api.nvim_create_autocmd`).
- Use `opts` for keymap option tables and callback option tables when that matches surrounding code.
- Use named global functions only when a Neovim command string needs to call them. Current example: `_G.set_terminal_keymaps()` in `lua/plugins/toggleterm.lua` is referenced by `autocmd! TermOpen term://* lua set_terminal_keymaps()`.
- Prefer `desc` on autocommands where the hook has non-obvious behavior.

---

## Common Mistakes

- Do not put plugin-dependent autocommands in `lua/core/autocmds.lua` if they require a plugin to be loaded.
- Do not create anonymous repeated autocommands without an augroup when reloading could duplicate behavior.
- Do not use web hook names like `useSomething`; this is Lua/Neovim event code.
- Do not do expensive work on every buffer/event unless guarded by filetype, pattern, or plugin event payload.
