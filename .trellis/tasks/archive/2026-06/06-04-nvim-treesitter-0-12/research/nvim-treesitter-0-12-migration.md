# Research: nvim-treesitter main branch migration for Neovim 0.12

- **Query**: Research nvim-treesitter main branch migration for Neovim 0.12 in this repo. Cover: correct lazy.nvim plugin spec, replacement for old require('nvim-treesitter').setup({ ensure_installed, highlight, indent }), parser install/update commands, enabling highlighting via vim.treesitter.start(), indentexpr, and compatibility pitfalls that can cause query/parser mismatch such as Invalid node type "tab".
- **Scope**: mixed
- **Date**: 2026-06-04

## Findings

### Files Found

| File Path | Description |
|---|---|
| `lua/plugins/treesitter.lua` | Current nvim-treesitter lazy.nvim spec and old option table. |
| `lazy-lock.json` | Current lock entry shows `nvim-treesitter` on branch `main`. |
| `.trellis/spec/backend/directory-structure.md` | Project convention: lazy plugin files return plugin spec tables; `lua/plugins/treesitter.lua` may return an array. |
| `.trellis/spec/frontend/component-guidelines.md` | Project convention: use existing lazy.nvim spec shapes; `config = function() ... end` for setup logic. |
| `.trellis/spec/frontend/type-safety.md` | Project convention: keep Lua option table shapes local and guard optional plugin APIs when startup can run before plugin/tool availability. |

### Code Patterns

Current repo code still uses the old nvim-treesitter configuration shape in `lua/plugins/treesitter.lua`:

```lua
-- lua/plugins/treesitter.lua:7-32
local default = {
  ensure_installed = {
    "lua",
    "vim",
    "html",
    "css",
    "javascript",
    "typescript",
    "json",
    "markdown",
    "markdown_inline",
    "vue",
    "rust",
  },
  indent = {
    enable = true,
  },
  highlight = {
    enable = true,
  },
  autotag = {
    enable = true,
  },
}
```

```lua
-- lua/plugins/treesitter.lua:34-42
return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup(default)
    end,
  },
}
```

`lazy-lock.json` indicates the plugin lock already references the main branch:

```json
// lazy-lock.json:20
"nvim-treesitter": { "branch": "main", "commit": "4916d6592ede8c07973490d9322f187e07dfefac" }
```

No other repo references were found for `require('nvim-treesitter')`, `nvim-treesitter.configs`, `vim.treesitter.start`, `:TSInstall`, `:TSUpdate`, local `queries/`, or local `parser/` paths beyond `lua/plugins/treesitter.lua`.

### Correct lazy.nvim Plugin Spec

The nvim-treesitter main README and setup docs state the main-branch rewrite should be treated as an incompatible setup from scratch for Neovim 0.12/nightly, and the recommended lazy.nvim spec is:

```lua
{
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate'
}
```

Docs explicitly say nvim-treesitter does not support lazy-loading and to always set `lazy = false`. `build = ':TSUpdate'` updates parsers when the plugin is installed or updated.

The old `master` branch remains available for backward compatibility with Neovim 0.11; main requires Neovim 0.12.0 or later according to the GitHub README result.

### Replacement for Old `setup({ ensure_installed, highlight, indent })`

Main-branch nvim-treesitter no longer uses the old feature-module option table shape from `nvim-treesitter.configs`. The plugin now mainly manages parser/query installation. The top-level `require('nvim-treesitter').setup { ... }` exists, but docs show it only for plugin-level options such as parser/query `install_dir`; defaults work without calling setup.

Old fields in the repo's `default` table map as follows:

| Old field | Main-branch replacement |
|---|---|
| `ensure_installed = { ... }` | Call `require('nvim-treesitter').install({ ... })` programmatically, or use `:TSInstall ...`. |
| `highlight = { enable = true }` | Enable Neovim's built-in highlighting per filetype/buffer with `vim.treesitter.start()`. |
| `indent = { enable = true }` | Set buffer-local indent expression: `vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"`. |
| `autotag = { enable = true }` | Not covered by main-branch nvim-treesitter setup docs found in this research; likely belongs to a separate autotag plugin if present. |

Main-branch setup examples from docs:

```lua
require('nvim-treesitter').setup {
  -- Directory to install parsers and queries to (prepended to runtimepath)
  install_dir = vim.fn.stdpath('data') .. '/site'
}
```

```lua
require('nvim-treesitter').install({ 'lua', 'python', 'javascript' })
```

`install()` is a no-op for already-installed parsers and is asynchronous by default. For bootstrapping scripts, docs show:

```lua
require('nvim-treesitter').install({ 'rust', 'javascript', 'zig' }):wait(300000)
```

### Parser Install / Update Commands

Documented commands and Lua APIs from nvim-treesitter main docs:

```vim
:TSInstall rust javascript python
:TSUpdate
:TSUpdate rust python
:TSInstall! rust
:TSInstallInfo
```

Lua equivalents:

```lua
require('nvim-treesitter').install({ 'rust', 'javascript', 'zig' })
require('nvim-treesitter').install({ 'rust', 'javascript', 'zig' }):wait(300000)
require('nvim-treesitter').update()
require('nvim-treesitter').update({ 'rust', 'python' })
require('nvim-treesitter').update():wait(300000)
```

The README emphasizes that nvim-treesitter is only guaranteed to work with parser revisions specified by its parser manifest; after upgrading the plugin, all installed parsers should be updated with `:TSUpdate`. The recommended lazy.nvim `build = ':TSUpdate'` automates this after plugin install/update.

### Enabling Highlighting via `vim.treesitter.start()`

Neovim's treesitter docs and nvim-treesitter docs state highlighting is provided by Neovim, not the old nvim-treesitter highlight module. It can be enabled for a buffer with:

```lua
vim.treesitter.start()
```

nvim-treesitter doc example uses a `FileType` autocmd:

```lua
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'rust', 'javascript', 'zig' },
  callback = function()
    vim.treesitter.start()
  end,
})
```

A migration guide example wraps this with `pcall(vim.treesitter.start)` in a `FileType` autocmd to avoid startup/filetype errors when a parser is unavailable.

Neovim docs note that `vim.treesitter.start()` requires a suitable parser and query on `runtimepath`.

### Indentation via `indentexpr`

Main-branch nvim-treesitter docs state treesitter-based indentation is provided by nvim-treesitter and is experimental. Enable it per filetype/buffer with:

```lua
vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
```

Full docs example combines highlight, folds, and indent in a `FileType` autocmd:

```lua
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'rust', 'javascript', 'zig' },
  callback = function()
    vim.treesitter.start()
    vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.wo.foldmethod = 'expr'
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
```

### Compatibility Pitfalls / Query-Parser Mismatch

Key documented pitfall: queries and parsers must come from compatible revisions. Errors such as `Invalid node type` or `Invalid field name` usually mean an updated query is being used with an outdated parser, or vice versa.

Relevant external findings:

- nvim-treesitter README: plugin is only guaranteed with parser versions specified in its parser manifest; run `:TSUpdate` after upgrading.
- Neovim docs: parsers are searched as `parser/{lang}.*` across `runtimepath`; if multiple parsers exist, the first one is used. Queries are searched under `queries/{lang}/{purpose}.scm`; by default, the first query on `runtimepath` is used unless marked with `; extends`.
- nvim-treesitter troubleshooting: for query errors, run `:checkhealth nvim-treesitter`, inspect `vim.treesitter.query.get_files(lang, query_type)`, then update parser and queries together with `:TSUpdate <lang>`.
- GitHub issue #8369 documents `Invalid node type "tab"` for the `vim` parser when a query referencing `tab` is paired with an older `tree-sitter-vim` parser. Maintainer response: do not mix and match queries and parsers; do not install tree-sitter parsers via distro/package sources in a way that shadows the expected parser.
- GitHub issue #8363 documents `Invalid node type "tab"` when bundled queries were used without the matching bundled parser version; maintainers point to outdated parser somewhere on `runtimepath` or non-standard precedence. One user traced it to an incompatible `tree-sitter` binary in `~/.local/share/nvim/mason/bin/tree-sitter` being used over the expected CLI.

Useful diagnostic commands from docs/issues:

```vim
:checkhealth nvim-treesitter
:TSUpdate
:TSUpdate vim
:TSInstall! vim
:echo nvim_get_runtime_file('*/vim.so', v:true)
:echo nvim_get_runtime_file('queries/vim/*.scm', v:true)
```

Lua diagnostic snippets from troubleshooting docs:

```lua
local lang = 'vim'
local query_type = 'highlights'
local files = vim.treesitter.query.get_files(lang, query_type)
for _, file in ipairs(files) do
  print(file)
end
```

```lua
local config = require('nvim-treesitter.config')
local parsers = require('nvim-treesitter.parsers')
local lang = 'vim'
local current = config.get_installed_revision(lang)
local latest = parsers[lang].install_info.revision
print('Current: ' .. (current or 'none'))
print('Latest: ' .. (latest or 'none'))
```

## External References

- [nvim-treesitter README main branch](https://github.com/nvim-treesitter/nvim-treesitter/blob/main/README.md) — Main-branch requirements, lazy.nvim spec, setup/install/update APIs, `vim.treesitter.start()`, parser compatibility warning.
- [nvim-treesitter doc main branch](https://github.com/nvim-treesitter/nvim-treesitter/blob/main/doc/nvim-treesitter.txt) — Manual feature enabling examples, `install()`, `update()`, and `indentexpr()` help text.
- [nvim-treesitter setup docs](https://nvim-treesitter-nvim-treesitter.mintlify.app/guides/setup) — Explicit `lazy = false`, `build = ':TSUpdate'`, setup defaults, install directory behavior.
- [nvim-treesitter installation docs](https://nvim-treesitter-nvim-treesitter.mintlify.app/installation) — lazy.nvim installation, `:TSInstall`, `:TSUpdate`, Lua install/update APIs.
- [nvim-treesitter parser docs](https://nvim-treesitter-nvim-treesitter.mintlify.app/concepts/parsers) — Parser installation/update methods and parser install path.
- [nvim-treesitter troubleshooting docs](https://nvim-treesitter-nvim-treesitter.mintlify.app/advanced/troubleshooting) — Query/parser mismatch diagnosis and remediation.
- [Neovim treesitter docs](https://neovim.io/doc/user/treesitter/) — Runtimepath parser/query precedence and `vim.treesitter.start()` semantics.
- [nvim-treesitter issue #8369](https://github.com/nvim-treesitter/nvim-treesitter/issues/8369) — `Invalid node type "tab"` caused by incompatible vim parser/query versions.
- [nvim-treesitter issue #8363](https://github.com/nvim-treesitter/nvim-treesitter/issues/8363) — `Invalid tab` discussion; outdated parser/runtimepath and incompatible CLI binary pitfalls.

## Related Specs

- `.trellis/spec/backend/directory-structure.md` — Plugin specs live under `lua/plugins/`, lazy.nvim imports the folder, and `lua/plugins/treesitter.lua` may return an array.
- `.trellis/spec/frontend/component-guidelines.md` — Existing lazy.nvim spec shape and `config = function() ... end` pattern.
- `.trellis/spec/frontend/type-safety.md` — Keep Lua option tables local; guard optional plugin APIs when availability can vary during startup.

## Caveats / Not Found

- No local `queries/` or `parser/` directories were found by the performed searches; the mismatch risk is therefore from runtimepath/data/plugin/system parser/query sources, not from repo-local query files.
- No local use of `vim.treesitter.start()` or treesitter `indentexpr` was found outside the current treesitter plugin file.
- External docs found through search disagree slightly on stated minimum Neovim version in generated docs snippets (`0.11+` in some Mintlify pages versus `0.12.0 or later` in the GitHub main README). For this task's Neovim 0.12 migration, the main README is the relevant source.
