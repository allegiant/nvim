# Logging Guidelines

> User-facing notification conventions for this Neovim configuration.

---

## Overview

There is no backend logging framework or structured log pipeline. Runtime feedback is delivered through Neovim UI primitives:

- `vim.notify(...)` for informational, warning, and error notifications.
- `vim.api.nvim_echo(...)` for startup/bootstrap failures before plugin notification UI is guaranteed.
- Plugin-owned notification UI from `snacks.nvim` (`notifier.enabled = true` in `lua/plugins/snacks.lua`).

For shared Lua helpers, prefer `lua/core/utils.lua`, which wraps `vim.notify` in a fast-event-safe scheduler.

---

## Log Levels

Use Neovim log levels, not custom strings:

- `vim.log.levels.INFO` for normal status messages. Existing wrapper: `utils.info(msg)` in `lua/core/utils.lua`.
- `vim.log.levels.WARN` for recoverable warnings. Existing wrapper: `utils.warn(msg)`.
- `vim.log.levels.ERROR` for failed operations that need user attention. Existing examples: `utils.err(msg)` and the ShaDa cleanup error in `lua/core/autocmds.lua`.

`lua/plugins/snacks.lua` currently sends LSP progress through `vim.notify(..., "info", { id = "lsp_progress", title = client.name, ... })` so progress updates replace the same notification instead of spamming.

---

## Structured Logging

No structured logging format exists. When a notification needs metadata, pass it in Neovim's notify options table as demonstrated by LSP progress in `lua/plugins/snacks.lua`:

```lua
vim.notify(table.concat(msg, "\n"), "info", {
  id = "lsp_progress",
  title = client.name,
  opts = function(notif)
    notif.icon = #progress[client.id] == 0 and " " or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
  end,
})
```

Keep notifications concise and user-actionable. Do not introduce a JSON logger or file logger unless the repository gains a real runtime need.

---

## What to Log

- Required startup failures with command output, as in `lua/config/lazy.lua` when `git clone` fails.
- Cleanup or maintenance errors that the user may need to acknowledge, as in `lua/core/autocmds.lua` when empty temporary ShaDa files cannot be deleted.
- Long-running editor progress where the notification is updated in place, as in the `LspProgress` autocmd in `lua/plugins/snacks.lua`.

---

## What NOT to Log

- Do not log secrets, tokens, credentials, or full environment dumps.
- Do not log high-frequency editor events without a stable notification `id`; use in-place updates to avoid notification spam.
- Do not log local filesystem paths unless the path is needed for a user-actionable error.
- Do not add persistent log files to the repository.
