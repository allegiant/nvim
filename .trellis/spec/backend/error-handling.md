# Error Handling

> Error handling conventions for Lua runtime and Neovim plugin setup.

---

## Overview

Errors are handled defensively at integration boundaries: plugin bootstrap, optional dependencies, external tool availability, and cleanup hooks. There are no custom error classes and no API responses.

Observed patterns:

- Fail loudly only when Neovim cannot continue, as in `lua/config/lazy.lua` when cloning lazy.nvim fails.
- Gracefully return when an optional dependency or Mason package is unavailable, as in `lua/lsp/lua_ls.lua`, `lua/lsp/jsonls.lua`, `lua/lsp/pylsp.lua`, and `lua/lsp/vue_ls.lua`.
- Notify the user through Neovim UI for runtime cleanup failures, as in `lua/core/autocmds.lua`.

---

## Error Types

This codebase uses Neovim/Lua primitives instead of custom error types:

- `pcall(require, "mason-registry")` to detect optional module availability.
- `vim.v.shell_error` after `vim.fn.system(...)` for shell command failure.
- integer status accumulation from `vim.fn.delete(...)` for cleanup operations.
- `vim.log.levels.ERROR`, `WARN`, and `INFO` through `vim.notify` wrappers in `lua/core/utils.lua`.

---

## Error Handling Patterns

### Bootstrap failure should show context and exit

`lua/config/lazy.lua` shows the expected pattern for a required dependency:

```lua
local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
if vim.v.shell_error ~= 0 then
  vim.api.nvim_echo({
    { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
    { out,                            "WarningMsg" },
    { "\nPress any key to exit..." },
  }, true, {})
  vim.fn.getchar()
  os.exit(1)
end
```

### Optional integrations should return early

LSP modules must not throw just because Mason or a language server is missing:

```lua
local present, mason_registry = pcall(require, "mason-registry")
if not present then
  return
end

local installed = mason_registry.is_installed("python-lsp-server")
if not installed then
  return
end
```

### Fast-event notification must schedule safely

Use `core.utils` notification helpers when adding shared notifications that may run inside fast events:

```lua
local fast_event_aware_notify = function(msg, level, opts)
  if vim.in_fast_event() then
    vim.schedule(function()
      vim.notify(msg, level, opts)
    end)
  else
    vim.notify(msg, level, opts)
  end
end
```

---

## API Error Responses

Not applicable. This repository does not expose HTTP/API endpoints.

---

## Common Mistakes

- Do not call `require("mason-registry")` directly in LSP modules without `pcall`; missing Mason must not break startup.
- Do not silently ignore bootstrap failures that make Neovim unusable; show the captured output and stop.
- Do not use `vim.notify` directly from code that can execute in fast events; use the scheduled wrapper pattern from `lua/core/utils.lua`.
- Do not add web/API response conventions to this repo; it has no server surface.
