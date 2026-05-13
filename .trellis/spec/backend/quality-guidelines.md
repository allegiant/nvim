# Quality Guidelines

> Code quality standards for core Lua/config/runtime changes.

---

## Overview

This repository favors small Lua modules, lazy-loaded plugin specs, and defensive startup behavior. There is no project test suite or formatter config checked in. Quality checks are therefore a mix of static Lua syntax checks, Neovim startup checks, and manual inspection against existing conventions.

Existing formatting reality:

- Lua indentation is generally 2 spaces in most files (`lua/core/options.lua`, `lua/plugins/snacks.lua`, `lua/plugins/blink.lua`).
- Some LSP formatter settings specify 4 spaces for Lua in `lua/lsp/lua_ls.lua`; document the current mixed state rather than enforcing a new formatter.
- Strings are mixed single/double quotes; follow the surrounding file.

---

## Forbidden Patterns

- Do not put plugin setup directly in `init.lua`; keep `init.lua` as routing and ordered requires only.
- Do not add new LSP setup that errors when Mason or the server package is missing. Follow the `pcall(require, "mason-registry")` and `is_installed(...)` pattern.
- Do not duplicate generic helpers across plugin files. Reuse or extend `lua/core/utils.lua` when the same logic has multiple call sites.
- Do not commit local Neovim data/cache directories or generated runtime state.
- Do not add secrets, tokens, credentials, or machine-specific absolute paths to config files.

---

## Required Patterns

- Keep lazy.nvim plugin specs under `lua/plugins/` and return a spec table directly.
- Use lazy.nvim triggers (`event`, `cmd`, `keys`, `priority`, `lazy`) where the plugin already follows that pattern. Examples: `lua/plugins/lspconfig.lua` uses `event = { "BufReadPre", "BufNewFile" }`; `lua/plugins/conform.lua` uses `event = { "BufWritePre" }` and `cmd = { "ConformInfo" }`.
- Put user-facing keymap descriptions in plugin `keys` entries. Existing examples include `desc = "Find Files"` in `lua/plugins/snacks.lua` and `desc = "Format buffer"` in `lua/plugins/conform.lua`.
- Keep platform-specific behavior guarded: `vim.g.vscode` in `init.lua`, `vim.g.neovide` in `init.lua`, `vim.fn.has("win32")` in `lua/plugins/toggleterm.lua`, and `vim.fn.has('wsl')` in `lua/core/options.lua`.
- For autocommands with reusable identity, use augroups as in `lua/core/autocmds.lua` for the ShaDa cleanup hook.

---

## Testing Requirements

No formal tests are present. For changes to this configuration, run the lightest available verification:

```powershell
nvim --headless "+luafile init.lua" "+qa"
```

If Neovim is unavailable in the environment, at minimum run Lua syntax checks on changed files when a Lua interpreter is available, and manually inspect module paths and `require(...)` names.

---

## Code Review Checklist

- Startup order still matches `init.lua` and does not load normal plugins inside VS Code mode.
- New plugin specs are discoverable through the `{ import = "plugins" }` setup in `lua/config/lazy.lua`.
- New LSP modules are called from `lua/plugins/lspconfig.lua` and guard Mason/server availability.
- Keymaps use existing leader groups and include `desc` when defined through lazy.nvim `keys`.
- Platform-specific code is guarded and does not break Windows, WSL, Neovide, or vscode-neovim paths.
- No local generated state, secrets, or machine-only paths are introduced.
