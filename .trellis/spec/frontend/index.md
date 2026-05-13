# Frontend Development Guidelines

> Editor-facing UI, keymap, and plugin interaction guidelines for this Neovim configuration.

---

## Overview

This repository has no web frontend. In Trellis terms, the frontend layer maps to the editor interaction surface: plugin UI configuration, keymaps, completion/picker/statusline behavior, terminal UI, VS Code Neovim integration, and Neovide settings.

---

## Guidelines Index

| Guide | Description | Status |
|-------|-------------|--------|
| [Directory Structure](./directory-structure.md) | UI/plugin-facing organization and file layout | Filled |
| [Component Guidelines](./component-guidelines.md) | Plugin UI option patterns and composition | Filled |
| [Hook Guidelines](./hook-guidelines.md) | Autocommands, lazy events, and callbacks | Filled |
| [State Management](./state-management.md) | Neovim globals/options, plugin-local state, lockfiles | Filled |
| [Quality Guidelines](./quality-guidelines.md) | Keymap/UI review standards and verification | Filled |
| [Type Safety](./type-safety.md) | Lua language-server and runtime validation patterns | Filled |

---

## Project-Specific Scope

Use these frontend guidelines when changing:

- `lua/core/mappings.lua`
- `lua/plugins/*.lua` files that define keymaps, windows, pickers, completion, statusline, bufferline, terminal, dashboard, or notifications
- `lua/config/vscode.lua`
- `lua/config/neovide.lua`

For startup, shared helpers, LSP setup, and persisted config state, also read the backend guidelines.

---

**Language**: All documentation should be written in **English**.
