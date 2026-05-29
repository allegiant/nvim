# Backend Development Guidelines

> Core Lua/config/runtime guidelines for this Neovim configuration.

---

## Overview

This repository is a Neovim configuration, not a backend service. In Trellis terms, the backend layer maps to startup/runtime concerns: `init.lua`, `lua/core/`, `lua/config/`, `lua/plugins/lsp/`, plugin bootstrap, lockfiles, and defensive integration with external tools such as git, Mason, language servers, and formatters.

---

## Guidelines Index

| Guide | Description | Status |
|-------|-------------|--------|
| [Directory Structure](./directory-structure.md) | Core module organization and file layout | Filled |
| [Database Guidelines](./database-guidelines.md) | No database; persisted config/lockfile conventions | Filled |
| [Error Handling](./error-handling.md) | Bootstrap, optional dependency, and notification error patterns | Filled |
| [Quality Guidelines](./quality-guidelines.md) | Lua config standards, forbidden patterns, verification | Filled |
| [Logging Guidelines](./logging-guidelines.md) | Neovim notification/log level conventions | Filled |

---

## Project-Specific Scope

Use these backend guidelines when changing:

- `init.lua`
- `lua/core/*.lua`
- `lua/config/lazy.lua`
- `lua/plugins/lsp/*.lua`
- runtime helpers, lockfiles, snippets, or task templates

For editor-facing keymaps and plugin UI behavior, also read the frontend guidelines.

---

**Language**: All documentation should be written in **English**.
