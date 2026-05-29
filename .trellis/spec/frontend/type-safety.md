# Type Safety

> Lua language-server and runtime validation conventions for this Neovim configuration.

---

## Overview

This project uses Lua, not TypeScript. Type safety is provided by lua-language-server diagnostics, defensive runtime checks, and simple table shapes. There are no TypeScript type files, schema validators, or generated types.

Relevant files:

- `.luarc.json` declares workspace globals such as `vim` and `Snacks`.
- `lua/plugins/lsp/lua_ls.lua` configures lua-language-server diagnostics, runtime version, telemetry, formatting, and workspace library.
- Plugin option tables in `lua/plugins/*.lua` rely on plugin-documented shapes rather than local type definitions.

---

## Type Organization

- Keep Lua option table shapes local to the plugin or module that uses them. Examples: `local opts = { ... }` in `lua/plugins/blink.lua`; `local default = { ... }` in `lua/plugins/treesitter.lua`.
- Keep module APIs simple. LSP modules return `M` with a single `setup()` method; `lua/core/utils.lua` returns a table of helper functions.
- Do not create separate type modules unless there are multiple concrete call sites that need shared definitions.

---

## Validation

Runtime validation is done with lightweight Lua/Neovim checks:

- `type(value) ~= "table"` guard in `lua/plugins/snacks.lua` before reading LSP progress payload fields.
- `pcall(require, "mason-registry")` in LSP modules before accessing Mason APIs.
- `mason_registry.is_installed(...)` before enabling language servers.
- `if type(obj) ~= "table" then return obj end` in `lua/core/utils.lua` before deep-copy recursion.
- `vim.fn.has(...)` and `vim.fn.executable(...)` checks for platform/tool capabilities.

---

## Common Patterns

### Simple module table

```lua
local M = {}

M.setup = function()
  -- setup logic
end

return M
```

Used by LSP modules such as `lua/plugins/lsp/lua_ls.lua`, `lua/plugins/lsp/jsonls.lua`, and `lua/plugins/lsp/pylsp.lua`.

### Defensive payload check

```lua
local client = vim.lsp.get_client_by_id(ev.data.client_id)
local value = ev.data.params.value
if not client or type(value) ~= "table" then
  return
end
```

Used in `lua/plugins/snacks.lua` before formatting LSP progress notifications.

### Recursive table helper

`lua/core/utils.lua` implements `utils.clone` by checking `type(obj)` before recursing and preserving metatables.

---

## Forbidden Patterns

- Do not add TypeScript conventions, `any`, React prop types, or Zod/Yup validation to this repo; they do not match the Lua Neovim config.
- Do not silence lua-language-server warnings globally unless the warning is already intentionally disabled in `lua/plugins/lsp/lua_ls.lua` or `.luarc.json`.
- Do not access optional plugin APIs without guarding availability when startup can run before that plugin/tool exists.
- Do not rely on undeclared globals. If a global is intentionally provided by the runtime or plugin and lua-language-server needs it, update `.luarc.json` or the lua_ls diagnostics globals consistently.
