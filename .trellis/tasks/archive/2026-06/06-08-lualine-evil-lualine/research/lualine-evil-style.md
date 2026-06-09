# Research: lualine.nvim evil_lualine style

- **Query**: Research lualine.nvim configuration conventions and the "evil_lualine" style/theme pattern for Neovim. Include: (1) 2-4 comparable lualine setups/patterns, (2) what evil_lualine typically means visually/configurationally, (3) relevant lualine.nvim options from official docs (sections, separators, theme, globalstatus, disabled_filetypes), (4) how to map this into this repo's existing lazy.nvim plugin spec with minimal changes.
- **Scope**: mixed
- **Date**: 2026-06-08

## Findings

### Files Found

| File Path | Description |
|---|---|
| `lua/plugins/lualine.lua` | Existing lazy.nvim plugin spec for `nvim-lualine/lualine.nvim`; currently only sets `options.theme = "gruvbox-material"` and keeps custom `sections` commented out (`lua/plugins/lualine.lua:1-24`). |
| `lua/config/lazy.lua` | lazy.nvim imports all plugin specs via `{ import = "plugins" }`, sets install colorscheme to `gruvbox-material`, and enables update checker (`lua/config/lazy.lua:24-35`). |
| `lazy-lock.json` | Current lockfile pins `lualine.nvim` to commit `221ce6b2d999187044529f49da6554a92f740a96`, `lazy.nvim` to `306a05526ada86a7b30af95c5cc81ffba93fef97`, and `gruvbox-material` to `11d779b26a9ab2b3db8c22c6ac9fb6e8ed4fea79`. |
| `.trellis/spec/frontend/directory-structure.md` | Treats plugin UI/statusline behavior as the repo's frontend surface and identifies `lua/plugins/lualine.lua` as the statusline theme/options owner (`.trellis/spec/frontend/directory-structure.md:9-16`, `:22-34`). |
| `.trellis/spec/frontend/component-guidelines.md` | Documents the preferred lazy.nvim spec shape, `opts` for declarative plugin configuration, and statusline theme convention (`.trellis/spec/frontend/component-guidelines.md:20-40`, `:53-60`). |

No repository-local `evil_lualine` implementation was found by code search; the relevant pattern is external and comes from lualine.nvim's official `examples/evil_lualine.lua`.

### Code Patterns

#### Existing repo lazy.nvim pattern

Current repo statusline plugin spec is minimal and declarative:

```lua
return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    options = {
      theme = "gruvbox-material",
    },
    -- sections = { ... }
  }
}
```

Source: `lua/plugins/lualine.lua:1-24`.

The repo already imports `lua/plugins/*.lua` specs from lazy.nvim:

```lua
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  install = { colorscheme = { "gruvbox-material" } },
  checker = { enabled = true },
})
```

Source: `lua/config/lazy.lua:24-35`.

lazy.nvim's official plugin-spec docs say `opts` can be a table or function, is passed to `Plugin.config()`, and setting it implies config. The default config runs `require(MAIN).setup(opts)`, and `opts` is the recommended way to configure plugins. Source: `folke/lazy.nvim` `doc/lazy.nvim.txt:301-312`.

#### Comparable lualine setups / patterns

1. **Default/simple lualine pattern**
   - lualine's default layout divides the statusline into `A | B | C ... X | Y | Z` sections. The README shows defaults: `lualine_a = { "mode" }`, `lualine_b = { "branch", "diff", "diagnostics" }`, `lualine_c = { "filename" }`, `lualine_x = { "encoding", "fileformat", "filetype" }`, `lualine_y = { "progress" }`, `lualine_z = { "location" }`.
   - The current repo is closest to this pattern because it leaves sections at defaults and only changes `options.theme` to `gruvbox-material`.
   - Reference: lualine README default configuration (`README.md:137-193`); repo source `lua/plugins/lualine.lua:6-23`.

2. **Official `evil_lualine.lua` / Eviline pattern**
   - Official example header calls it "Eviline config for lualine" and lives at `examples/evil_lualine.lua`.
   - It defines a local `colors` palette and `conditions` helpers (`buffer_not_empty`, `hide_in_width`, `check_git_workspace`).
   - It sets `component_separators = ''` and `section_separators = ''`, then uses a minimal custom theme table with only `normal.c` and `inactive.c` background/foreground.
   - It empties default `lualine_a`, `lualine_b`, `lualine_y`, and `lualine_z`, then fills only `lualine_c` and `lualine_x` through helper functions `ins_left` and `ins_right`.
   - It uses a mode-color function keyed by `vim.fn.mode()`, left/right edge bars, conditional file/LSP/git components, diagnostics color tables, and a `%=` mid-section separator inside `lualine_c`.
   - References: `nvim-lualine/lualine.nvim` official `examples/evil_lualine.lua:36-79`, `:81-148`, `:150-221`.

3. **Official `bubbles.lua` pattern**
   - Uses a custom Lua theme table with per-mode `a/b/c` sections.
   - Disables component separators but keeps rounded section separators: `section_separators = { left = '', right = '' }`.
   - Keeps conventional sections (`mode`, `filename`, `branch`, `filetype`, `progress`, `location`) but wraps edge components with local separators.
   - Useful contrast: visually shaped/rounded, but simpler than evil_lualine because it does not collapse everything into `lualine_c`/`lualine_x` helper insertion.
   - Reference: `nvim-lualine/lualine.nvim` official `examples/bubbles.lua:16-62`.

4. **LazyVim lualine pattern**
   - Keeps the lazy.nvim plugin spec and uses `event = "VeryLazy"` plus an `opts = function()` to build dynamic options.
   - Sets `theme = "auto"`, derives `globalstatus` from `vim.o.laststatus == 3`, disables statusline for starter/dashboard/lazy filetypes, and adds integration components such as lazy update count, Noice status, DAP status, diff, diagnostics, and root/path helpers.
   - Useful contrast: shows how a lazy.nvim config can remain spec-local while becoming dynamic; however, it is broader than the repo's current minimal lualine file.
   - Reference: `LazyVim/LazyVim` `lua/lazyvim/plugins/ui.lua:64-168`.

### What `evil_lualine` Typically Means

`evil_lualine` usually refers to the official lualine example file `examples/evil_lualine.lua`; the file header calls the visual style "Eviline". Visually/configurationally it means:

- **Flat/statusline-bar look**: both `component_separators` and `section_separators` are disabled, so the statusline reads as a continuous dark bar rather than powerline blocks.
- **Dark base theme**: a small hardcoded palette uses dark background (`#202328`) and light foreground (`#bbc2cf`) with accent colors for mode/git/diagnostics.
- **Mode-colored icon rather than default mode block**: a function returns an icon and colors it based on `vim.fn.mode()`; normal, insert, visual, command, replace, terminal, and other modes map to different colors.
- **Manual component insertion**: defaults in `a/b/y/z` are removed; left-side components are inserted into `lualine_c`, right-side components into `lualine_x` via helper functions.
- **Center split inside `lualine_c`**: a `%=` component is inserted to separate left content from the middle/right content.
- **Conditional compactness**: helpers hide components when the buffer is empty or the window is narrow.
- **Rich but local components**: file size/name/location/progress, diagnostics, current LSP name, encoding, fileformat, branch, and diff are all explicitly configured in the same file.

### Official lualine.nvim Options Relevant Here

#### `sections` / `inactive_sections`

lualine organizes statusline sections as:

```text
+-------------------------------------------------+
| A | B | C                             X | Y | Z |
+-------------------------------------------------+
```

Default active sections from the README/source are:

```lua
sections = {
  lualine_a = { 'mode' },
  lualine_b = { 'branch', 'diff', 'diagnostics' },
  lualine_c = { 'filename' },
  lualine_x = { 'encoding', 'fileformat', 'filetype' },
  lualine_y = { 'progress' },
  lualine_z = { 'location' },
}
```

Default inactive sections keep only filename/location:

```lua
inactive_sections = {
  lualine_a = {},
  lualine_b = {},
  lualine_c = { 'filename' },
  lualine_x = { 'location' },
  lualine_y = {},
  lualine_z = {},
}
```

References: lualine README `README.md:114-123`, `:173-193`; current source `lua/lualine/config.lua:42-61`.

#### Separators

Official docs define two separator levels:

- `section_separators`: separators between sections.
- `component_separators`: separators between components inside a section.

The README notes that `left` applies to left-most sections `a`, `b`, `c`, while `right` applies to right-most sections `x`, `y`, `z`. Separators can be customized with glyph tables or disabled entirely:

```lua
options = {
  section_separators = { left = '', right = '' },
  component_separators = { left = '', right = '' },
}

options = { section_separators = '', component_separators = '' }
```

References: lualine README `README.md:242-265`; official `evil_lualine.lua:38-42`.

#### `theme`

`options.theme` may be a string such as `'auto'`, `'gruvbox'`, or this repo's current `'gruvbox-material'`, or a custom Lua table.

Official theme-writing docs say a custom theme defines colors for Vim modes (`normal`, `insert`, `visual`, `replace`, `command`, `inactive`) and lualine sections. Section entries define `fg`, `bg`, and optionally `gui`; `x/y/z` may be specified, and if omitted they default from `c/b/a` respectively. References: lualine wiki "Writing a theme"; lualine README theme customization `README.md:214-238`.

`evil_lualine` uses a minimal custom table:

```lua
theme = {
  normal = { c = { fg = colors.fg, bg = colors.bg } },
  inactive = { c = { fg = colors.fg, bg = colors.bg } },
}
```

Reference: official `examples/evil_lualine.lua:42-48`.

#### `globalstatus`

The README default configuration shows `globalstatus = false`, with option docs describing it as enabling one global statusline at the bottom of Neovim instead of one per window, available in Neovim 0.7+. Reference: lualine README `README.md:150-153`, `:415-417`.

Current lualine source differs slightly: the default is `globalstatus = vim.go.laststatus == 3`, meaning it follows Neovim's `laststatus=3` setting. Reference: current `lua/lualine/config.lua:20-23`.

LazyVim uses a similar explicit mapping: `globalstatus = vim.o.laststatus == 3`. Reference: `LazyVim/LazyVim` `lua/lazyvim/plugins/ui.lua:88-93`.

#### `disabled_filetypes`

Official docs show a nested table:

```lua
disabled_filetypes = {
  statusline = {},
  winbar = {},
}
```

Option docs describe `statusline` as filetypes ignored only for the statusline and `winbar` as filetypes ignored only for the winbar. Reference: lualine README `README.md:146-150`, `:390-393`.

Current lualine source normalizes legacy list-style values by copying them into both `statusline` and `winbar`, then removing numeric entries. Reference: current `lua/lualine/config.lua:89-107`.

### Mapping Into This Repo's Existing lazy.nvim Plugin Spec

Minimal-change mapping stays entirely in `lua/plugins/lualine.lua` because:

- The repo already owns statusline theme/options in that file (`.trellis/spec/frontend/directory-structure.md:22-34`).
- The repo's component guidelines prefer `opts = { ... }` for declarative plugin configuration and only use `config = function() ... end` when setup logic is needed (`.trellis/spec/frontend/component-guidelines.md:20-40`).
- lazy.nvim will pass `opts` to `require("lualine").setup(opts)` automatically (`folke/lazy.nvim` docs `doc/lazy.nvim.txt:301-312`).

Observed minimal-change shape:

```lua
return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    options = {
      theme = {
        normal = { c = { fg = "#bbc2cf", bg = "#202328" } },
        inactive = { c = { fg = "#bbc2cf", bg = "#202328" } },
      },
      component_separators = "",
      section_separators = "",
      -- globalstatus = true or vim.o.laststatus == 3,
      -- disabled_filetypes = { statusline = { "lazy" }, winbar = {} },
    },
    sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {
        -- left-side evil_lualine-style components
      },
      lualine_x = {
        -- right-side evil_lualine-style components
      },
      lualine_y = {},
      lualine_z = {},
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {},
    },
  },
}
```

If the implementation needs helper functions such as `ins_left`, `ins_right`, dynamic mode-color lookup, or local `conditions`, those can still be kept in `lua/plugins/lualine.lua` above the returned spec and assigned into `opts.sections`. This preserves the existing single-file lazy.nvim spec shape and does not require changes to `lua/config/lazy.lua`.

The existing commented lazy updates component in `lua/plugins/lualine.lua:10-17` maps to the official lazy.nvim statusline component pattern:

```lua
{
  require("lazy.status").updates,
  cond = require("lazy.status").has_updates,
  color = { fg = "#ff9e64" },
}
```

Reference: `folke/lazy.nvim` docs show the same lualine integration; repo already enables `checker = { enabled = true }` in `lua/config/lazy.lua:33-34`, which lazy.nvim requires for update counts.

### External References

- [nvim-lualine/lualine.nvim README](https://github.com/nvim-lualine/lualine.nvim/blob/master/README.md) — official installation, sections, default configuration, theme, separators, component options, and option descriptions.
- [nvim-lualine/lualine.nvim current config source](https://github.com/nvim-lualine/lualine.nvim/blob/master/lua/lualine/config.lua) — current default table and `disabled_filetypes` normalization behavior.
- [Official `examples/evil_lualine.lua`](https://github.com/nvim-lualine/lualine.nvim/blob/master/examples/evil_lualine.lua) — source of the Eviline/evil_lualine pattern.
- [Official `examples/bubbles.lua`](https://github.com/nvim-lualine/lualine.nvim/blob/master/examples/bubbles.lua) — comparable custom theme/separator example.
- [lualine wiki: Writing a theme](https://github.com/nvim-lualine/lualine.nvim/wiki/Writing-a-theme) — custom theme structure and section/mode color rules.
- [folke/lazy.nvim docs](https://github.com/folke/lazy.nvim/blob/main/doc/lazy.nvim.txt) — `opts` and default `require(MAIN).setup(opts)` behavior.
- [LazyVim lualine plugin spec](https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/ui.lua) — comparable lazy.nvim-based dynamic lualine setup.

### Related Specs

- `.trellis/spec/frontend/directory-structure.md` — editor UI/statusline ownership; `lua/plugins/lualine.lua` is the statusline theme/options file.
- `.trellis/spec/frontend/component-guidelines.md` — lazy.nvim spec shape; prefer `opts` for declarative plugin configuration; current lualine theme matches `gruvbox-material`.

## Caveats / Not Found

- No local `evil_lualine` code was found in this repo.
- lualine official README and current source differ on the displayed default for `globalstatus`: README shows `false`, while current source sets `vim.go.laststatus == 3`.
- The official evil_lualine example hardcodes palette colors and icons; icons/separator glyphs require a patched font for correct rendering, as lualine's README notes for statusline icons.
- This research did not modify `lua/plugins/lualine.lua`; it only maps the option surface and patterns for a future implementation step.
