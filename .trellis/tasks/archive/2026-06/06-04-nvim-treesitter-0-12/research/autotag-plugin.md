# Research: autotag plugin for nvim-treesitter main branch

- **Query**: Research how to restore old nvim-treesitter autotag behavior for Neovim 0.12 main-branch nvim-treesitter in this repo. Cover recommended plugin(s), lazy.nvim spec, current status/API for windwp/nvim-ts-autotag or alternatives, filetypes for html/vue/javascriptreact/typescriptreact/svelte/etc, dependency on nvim-treesitter, and pitfalls with nvim-treesitter main rewrite.
- **Scope**: mixed
- **Date**: 2026-06-04

## Findings

### Files Found

| File Path | Description |
|---|---|
| `lua/plugins/treesitter.lua` | Current treesitter plugin spec still includes old `autotag = { enable = true }` inside the nvim-treesitter option table. |
| `lazy-lock.json` | Current lock entry shows `nvim-treesitter` on branch `main`. No `nvim-ts-autotag` lock entry was found in the searched output. |
| `.trellis/tasks/06-04-nvim-treesitter-0-12/research/nvim-treesitter-0-12-migration.md` | Existing research on nvim-treesitter main branch migration, including old config replacement and parser/query mismatch caveats. |
| `.trellis/spec/backend/quality-guidelines.md` | Project convention: keep lazy.nvim plugin specs under `lua/plugins/`, return a spec table directly, use existing lazy triggers where applicable, and keep startup defensive. |
| `.trellis/spec/frontend/type-safety.md` | Project convention: keep Lua option table shapes local to the plugin/module using them. |

### Code Patterns

Current local config uses the old nvim-treesitter module shape:

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

`lazy-lock.json` shows:

```json
// lazy-lock.json:20
"nvim-treesitter": { "branch": "main", "commit": "4916d6592ede8c07973490d9322f187e07dfefac" }
```

No local references were found for `windwp/nvim-ts-autotag`, `nvim-ts-autotag`, or a separate autotag plugin spec in the performed searches.

### Recommended Plugin / API

The directly relevant plugin remains `windwp/nvim-ts-autotag`:

- It provides treesitter-based auto-close and auto-rename of HTML-like tags.
- It requires Neovim `0.9.5` and up according to the current README.
- It requires the corresponding treesitter parser to be installed for the buffer language/filetype; the README explicitly notes it will not work unless parsers such as `html` are installed.
- Current setup is standalone:

```lua
require('nvim-ts-autotag').setup({
  opts = {
    enable_close = true,
    enable_rename = true,
    enable_close_on_slash = false,
  },
  per_filetype = {
    ["html"] = {
      enable_close = false,
    },
  },
})
```

The old integration through `nvim-treesitter.configs` is deprecated. The README warning says configuring via `nvim-treesitter.configs` has been deprecated and will be removed in `1.0.0`. Issue discussions also state to remove the old treesitter-module block and use plain `require("nvim-ts-autotag").setup()`.

### lazy.nvim Spec

The current `nvim-ts-autotag` README says lazy loading is not particularly necessary because the plugin is efficient in choosing when it needs to load. If lazy-loading is still used, the README names `BufReadPre` and `BufNewFile` as good events.

A minimal lazy.nvim shape consistent with the README/API and issue examples is:

```lua
{
  "windwp/nvim-ts-autotag",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("nvim-ts-autotag").setup()
  end,
}
```

A lazy-loaded shape using README-suggested events is:

```lua
{
  "windwp/nvim-ts-autotag",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("nvim-ts-autotag").setup({
      opts = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = false,
      },
    })
  end,
}
```

Issue #186 includes a lazy.nvim example with `lazy = false`, `dependencies = "nvim-treesitter/nvim-treesitter"`, and explicit `config = function() require 'nvim-ts-autotag'.setup() end`. The same issue notes that adding `opts = {}` can also trigger lazy.nvim setup, but explicit `config` is the clearest documented pattern in the issue thread.

For nvim-treesitter main itself, current README/search results show the recommended lazy.nvim spec remains eager:

```lua
{
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',
}
```

The main-branch README states `nvim-treesitter` does not support lazy-loading and that `setup()` is only needed for plugin-level settings such as `install_dir`.

### Filetypes / Languages

Current `nvim-ts-autotag` README lists support for:

- `astro`
- `dot`
- `glimmer`
- `handlebars`
- `html`
- `javascript`
- `jsx`
- `liquid`
- `vento`
- `markdown`
- `php`
- `rescript`
- `svelte`
- `tsx`
- `twig`
- `typescript`
- `vue`
- `xml`
- and more

For React-style filetypes specifically:

- Older issue #3 notes that for JS/TS React buffers, the relevant filetypes are `javascriptreact` and `typescriptreact`.
- README support list names parser/language-style labels `jsx` and `tsx`; in Neovim filetype terms these commonly correspond to `javascriptreact` and `typescriptreact` buffers.
- Issue #64 examples include explicit old-module filetype lists: `html`, `javascript`, `typescript`, `javascriptreact`, `typescriptreact`, `svelte`, `vue`, `tsx`, `jsx`, `rescript`, `css`, `lua`, `xml`, `php`, `markdown`. This is historical issue content, not the current recommended API, but it confirms the filetypes users associated with autotag behavior.

The README also supports aliases for similar languages:

```lua
require('nvim-ts-autotag').setup({
  aliases = {
    ["your language here"] = "html",
  }
})
```

and direct config extension via `require("nvim-ts-autotag.config.init")` when language tag node names differ.

### Dependency on nvim-treesitter / Parsers

`nvim-ts-autotag` depends on a parser being available for the language in the current buffer. The current README explicitly says it will not work unless treesitter parsers such as `html` are installed for the given filetype.

In nvim-treesitter main branch, the old `ensure_installed = { ... }` table is no longer the feature-module setup path. Existing migration research records the main-branch replacement as explicit parser install calls or commands:

```lua
require('nvim-treesitter').install({ 'html', 'javascript', 'typescript', 'tsx', 'vue', 'svelte', 'astro', 'php', 'markdown', 'xml' })
```

or commands:

```vim
:TSInstall html javascript typescript tsx vue svelte astro php markdown xml
:TSUpdate
```

Parser names are not always identical to Neovim filetype names. For React-style buffers, the parser/language names are commonly `javascript`/`jsx` and `typescript`/`tsx`, while filetypes can be `javascriptreact` and `typescriptreact`. `nvim-ts-autotag` issue discussion specifically mentions `javascriptreact` and `typescriptreact` as filetypes.

### Alternatives

No equally direct current alternative surfaced in the performed searches. `windwp/nvim-ts-autotag` is the established plugin for restoring the old `autotag = { enable = true }` behavior because the old behavior was historically provided as a nvim-treesitter module/integration around this plugin.

Related but different plugins/features, such as built-in treesitter highlighting, nvim-treesitter textobjects, or `treesitter-modules.nvim`, do not replace tag auto-close/auto-rename behavior in the search results reviewed.

### Pitfalls with nvim-treesitter Main Rewrite

- The old `autotag = { enable = true }` inside the nvim-treesitter config is no longer the current integration path for `nvim-ts-autotag`; README says setup through `nvim-treesitter.configs` is deprecated and will be removed in `1.0.0`.
- `nvim-treesitter` main branch is a full incompatible rewrite. Treating the old option table (`ensure_installed`, `highlight`, `indent`, `autotag`) as a `require('nvim-treesitter').setup(default)` feature-module setup is not the main-branch model.
- `nvim-ts-autotag` will not work without installed parsers. With nvim-treesitter main, parser installation should be done via `require('nvim-treesitter').install(...)` or `:TSInstall ...`, not the old `ensure_installed` module setup shape.
- Do not lazy-load `nvim-treesitter` itself; main README says it does not support lazy-loading. If `nvim-ts-autotag` is lazy-loaded, README suggests `BufReadPre` and `BufNewFile`.
- Query/parser mismatch remains relevant: the existing migration research records that nvim-treesitter main requires parsers and queries to come from compatible revisions, and `:TSUpdate` should run after upgrades. Runtimepath shadowing by stale parsers/queries can cause errors such as `Invalid node type`.
- Historical issue #248 reports deprecation warnings can persist when `autotag = { enable = true }` remains in treesitter config. The load-bearing takeaway is to remove the old treesitter-module autotag block when using standalone `require('nvim-ts-autotag').setup()`.

### External References

- [windwp/nvim-ts-autotag README](https://github.com/windwp/nvim-ts-autotag/blob/main/README.md) — Current setup API, supported languages, parser dependency, lazy-loading note, and deprecation warning for `nvim-treesitter.configs` setup.
- [windwp/nvim-ts-autotag issue #186](https://github.com/windwp/nvim-ts-autotag/issues/186) — Confirms parsers are required and standalone `require('nvim-ts-autotag').setup()` or lazy.nvim `opts = {}` is needed; old nvim-treesitter module setup should be removed.
- [windwp/nvim-ts-autotag issue #3](https://github.com/windwp/nvim-ts-autotag/issues/3) — Historical discussion around JS/TS React filetypes `javascriptreact` and `typescriptreact` and standalone setup behavior.
- [windwp/nvim-ts-autotag issue #64](https://github.com/windwp/nvim-ts-autotag/issues/64) — Historical filetype list examples including `html`, `javascriptreact`, `typescriptreact`, `svelte`, `vue`, `tsx`, `jsx`, `xml`, `php`, and `markdown`.
- [windwp/nvim-ts-autotag issue #248](https://github.com/windwp/nvim-ts-autotag/issues/248) — Deprecation warning discussion; one resolved cause was leaving `autotag = { enable = true }` in treesitter config.
- [nvim-treesitter README main branch](https://github.com/nvim-treesitter/nvim-treesitter/blob/main/README.md) — Main-branch rewrite warning, recommended lazy.nvim spec, no lazy-loading for nvim-treesitter, parser install/update API, and compatibility notes.
- [nvim-treesitter discussion #7927](https://github.com/nvim-treesitter/nvim-treesitter/discussions/7927) — Migration discussion showing `windwp/nvim-ts-autotag` as a dependency and standalone `require("nvim-ts-autotag").setup()` after main-branch treesitter setup.

### Related Specs

- `.trellis/spec/backend/quality-guidelines.md` — Plugin specs should remain under `lua/plugins/`, return spec tables directly, and follow existing lazy.nvim trigger patterns where applicable.
- `.trellis/spec/frontend/type-safety.md` — Keep Lua option table shapes local to the plugin/module that uses them.
- `.trellis/spec/frontend/state-management.md` — Do not hand-maintain plugin runtime state outside lazy.nvim/Mason conventions; avoid machine-specific runtime paths.

## Caveats / Not Found

- No local `nvim-ts-autotag` plugin spec or lockfile entry was found in the performed searches.
- No local repo queries/parsers were found in previous migration research; parser/query pitfalls are therefore likely to come from Neovim data/runtimepath/plugin/system locations rather than committed repo-local query files.
- The supported language list in the current README uses names such as `jsx` and `tsx`, while Neovim buffer filetypes for React files may be `javascriptreact` and `typescriptreact`; both naming layers matter when installing parsers and reasoning about filetype-specific behavior.
- External search did not surface a direct replacement plugin with better fit than `windwp/nvim-ts-autotag` for the old nvim-treesitter autotag behavior.
