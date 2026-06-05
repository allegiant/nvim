# Quality Guidelines

> Code quality standards for core Lua/config/runtime changes.

---

## Overview

This repository favors small Lua modules, lazy-loaded plugin specs, and defensive startup behavior. There is no project test suite or formatter config checked in. Quality checks are therefore a mix of static Lua syntax checks, Neovim startup checks, and manual inspection against existing conventions.

Existing formatting reality:

- Lua indentation is generally 2 spaces in most files (`lua/core/options.lua`, `lua/plugins/snacks.lua`, `lua/plugins/blink.lua`).
- Some LSP formatter settings specify 4 spaces for Lua in `lua/plugins/lsp/lua_ls.lua`; document the current mixed state rather than enforcing a new formatter.
- Strings are mixed single/double quotes; follow the surrounding file.

---

## Forbidden Patterns

- Do not put plugin setup directly in `init.lua`; keep `init.lua` as routing and ordered requires only.
- Do not add new LSP setup that errors when Mason or the server package is missing. Follow the `pcall(require, "mason-registry")` and `is_installed(...)` pattern.
- Do not duplicate generic helpers across plugin files. Reuse or extend `lua/core/utils.lua` when the same logic has multiple call sites.
- Do not commit local Neovim data/cache directories or generated runtime state.
- Do not commit Trellis session journals/indexes from `.trellis/workspace/`; this personal config keeps them local-only via `.trellis/.gitignore`.
- Do not add secrets, tokens, credentials, or machine-specific absolute paths to config files.

---

## Required Patterns

- Keep lazy.nvim plugin specs under `lua/plugins/` and return a spec table directly.
- Use lazy.nvim triggers (`event`, `cmd`, `keys`, `priority`, `lazy`) where the plugin already follows that pattern. Examples: `lua/plugins/lspconfig.lua` uses `event = { "BufReadPre", "BufNewFile" }`; `lua/plugins/conform.lua` uses `event = { "BufWritePre" }` and `cmd = { "ConformInfo" }`.
- Put user-facing keymap descriptions in plugin `keys` entries. Existing examples include `desc = "Find Files"` in `lua/plugins/snacks.lua` and `desc = "Format buffer"` in `lua/plugins/conform.lua`.
- Keep platform-specific behavior guarded: `vim.g.vscode` in `init.lua`, `vim.g.neovide` in `init.lua`, `vim.fn.has("win32")` in `lua/plugins/toggleterm.lua`, and `vim.fn.has('wsl')` in `lua/core/options.lua`.
- For autocommands with reusable identity, use augroups as in `lua/core/autocmds.lua` for the ShaDa cleanup hook.

---

## Scenario: nvim-treesitter Main Branch on Neovim 0.12

### 1. Scope / Trigger

- Trigger: Any change to `lua/plugins/treesitter.lua`, Treesitter parser installation, Treesitter highlighting/indent setup, or tag auto-close behavior.
- Applies when `nvim-treesitter` is on the `main` branch with Neovim 0.12+.

### 2. Signatures

- Plugin spec must keep `nvim-treesitter` eager-loaded:

```lua
{
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
}
```

- Parser installation uses the main-branch API:

```lua
require("nvim-treesitter").install(parsers)
```

- Highlighting is started per buffer with Neovim's built-in API:

```lua
pcall(vim.treesitter.start, args.buf)
```

- Tag auto-close/rename is owned by standalone `windwp/nvim-ts-autotag`, not by a Treesitter option table.

### 3. Contracts

- `parsers` is the single source of truth for installed parser names.
- `filetypes` lists buffer filetypes that should call `vim.treesitter.start()`; parser names and filetypes do not always match (`tsx` parser vs `typescriptreact` filetype).
- `markdown_inline` is a parser dependency for Markdown and should not be treated as a normal FileType pattern.
- Parser/query runtime artifacts live under Neovim data paths; do not commit generated parser/query files.

### 4. Validation & Error Matrix

- `Invalid node type ...` or `Invalid field name ...` -> query/parser version mismatch; run `:TSUpdate <lang>` or `:TSInstall! <lang>` and inspect runtimepath precedence.
- Missing parser for a filetype -> `vim.treesitter.start()` may fail; call it through `pcall` and avoid breaking startup.
- Missing `nvim-ts-autotag` parser dependency -> tags will not auto-close/rename for that language; add the parser to `parsers` when the filetype is in scope.
- Old `autotag = { enable = true }` under Treesitter setup -> deprecated integration path; remove it and configure `nvim-ts-autotag` directly.

### 5. Good/Base/Bad Cases

- Good: `nvim-treesitter` has `lazy = false`, `build = ":TSUpdate"`, guarded `install(parsers)`, guarded `vim.treesitter.start()`, and standalone `nvim-ts-autotag` setup.
- Base: New parser added to `parsers`; matching user-facing filetype added to `filetypes` only when buffers should enable highlighting/indent.
- Bad: Reintroducing `require("nvim-treesitter").setup({ ensure_installed = ..., highlight = ..., indent = ..., autotag = ... })` on the main branch.

### 6. Tests Required

- Run a headless startup check:

```powershell
nvim --headless "+luafile init.lua" "+qa"
```

- For query/parser errors, also open the triggering file headlessly and assert Neovim exits successfully, for example:

```powershell
nvim --headless "+luafile init.lua" "+edit lua/plugins/themes.lua" "+qa"
```

- Run `git diff --check` after editing Lua/plugin specs.

### 7. Wrong vs Correct

#### Wrong

```lua
require("nvim-treesitter").setup({
  ensure_installed = { "lua", "vim" },
  highlight = { enable = true },
  indent = { enable = true },
  autotag = { enable = true },
})
```

#### Correct

```lua
local ok, treesitter = pcall(require, "nvim-treesitter")
if ok then
  pcall(treesitter.install, parsers)
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = filetypes,
  callback = function(args)
    if pcall(vim.treesitter.start, args.buf) then
      vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})
```

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
- Helper-only plugin subdirectories under `lua/plugins/` do not include `init.lua`; otherwise lazy.nvim may import them as plugin specs.
- New LSP helper modules live under `lua/plugins/lsp/`, are called from `lua/plugins/lspconfig.lua`, and guard Mason/server availability.
- Keymaps use existing leader groups and include `desc` when defined through lazy.nvim `keys`.
- Platform-specific code is guarded and does not break Windows, WSL, Neovide, or vscode-neovim paths.
- No local generated state, secrets, or machine-only paths are introduced.
