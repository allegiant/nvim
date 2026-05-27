# Research: Snacks.bufdelete replacement for Bufferline

- **Query**: Research replacing `famiu/bufdelete.nvim` with `Snacks.bufdelete` in this Neovim config. Target file: `lua/plugins/bufferline.lua`; `lua/plugins/snacks.lua` already configures `folke/snacks.nvim` with `lazy = false`; current Bufferline dependency includes `famiu/bufdelete.nvim`, but close commands use `bdelete!` and `<leader>bd` uses `bdelete`. Focus: Snacks bufdelete API, force vs non-force behavior, Bufferline close_command function signature, and whether a dependency edge from Bufferline to Snacks is needed.
- **Scope**: mixed (internal project files, local installed plugin sources/docs, external docs search)
- **Date**: 2026-05-27

## Findings

### Files Found

| File Path | Description |
|---|---|
| `lua/plugins/bufferline.lua` | Target plugin spec. Defines Bufferline close behavior, dependencies, and buffer keymaps. |
| `lua/plugins/snacks.lua` | Existing `folke/snacks.nvim` plugin spec with `lazy = false` and `opts`. |
| `lua/config/lazy.lua` | Imports all plugin specs with `{ import = "plugins" }`. |
| `lazy-lock.json` | Pins `bufferline.nvim`, `bufdelete.nvim`, and `snacks.nvim` revisions. |
| `.trellis/tasks/05-27-bufferline-bufdelete/prd.md` | Active task PRD with replacement requirements and acceptance criteria. |
| `.trellis/spec/backend/quality-guidelines.md` | Project convention for lazy.nvim plugin specs and checks. |
| `.trellis/spec/frontend/type-safety.md` | Project convention about guarding optional plugin APIs when startup order can make them unavailable. |
| `C:\Users\alleg\AppData\Local\nvim-data\lazy\snacks.nvim\lua\snacks\bufdelete.lua` | Installed Snacks bufdelete implementation. |
| `C:\Users\alleg\AppData\Local\nvim-data\lazy\snacks.nvim\docs\bufdelete.md` | Installed Snacks bufdelete generated docs. |
| `C:\Users\alleg\AppData\Local\nvim-data\lazy\snacks.nvim\lua\snacks\init.lua` | Installed Snacks module initializer; creates global `Snacks` and lazy-loads submodules. |
| `C:\Users\alleg\AppData\Local\nvim-data\lazy\bufferline.nvim\lua\bufferline\commands.lua` | Installed Bufferline command/mouse handling implementation. |
| `C:\Users\alleg\AppData\Local\nvim-data\lazy\bufferline.nvim\doc\bufferline.txt` | Installed Bufferline help docs for close commands and mouse actions. |
| `C:\Users\alleg\AppData\Local\nvim-data\lazy\bufferline.nvim\lua\bufferline\types.lua` | Installed Bufferline option type annotations. |
| `C:\Users\alleg\AppData\Local\nvim-data\lazy\lazy.nvim\doc\lazy.nvim.txt` | Installed lazy.nvim docs for `opts`, `dependencies`, `lazy=false`, and startup ordering. |

### Code Patterns

#### Current project state

- `lua/plugins/bufferline.lua:7-8` sets both Bufferline close actions to Vim commands:

```lua
close_command = "bdelete! %d",
right_mouse_command = "bdelete! %d",
```

- `lua/plugins/bufferline.lua:43-46` declares `famiu/bufdelete.nvim` as a dependency, but the target file does not call `require("bufdelete")` or any `bufdelete.nvim` API:

```lua
dependencies = {
  "nvim-tree/nvim-web-devicons",
  'famiu/bufdelete.nvim'
},
```

- `lua/plugins/bufferline.lua:52` maps `<leader>bd` to non-bang `:bdelete` for the current buffer:

```lua
{ "<leader>bd", "<cmd>bdelete<CR>", desc = "Close" },
```

- `lua/plugins/snacks.lua:1-4` configures Snacks as an eager/start plugin:

```lua
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
```

- `lua/plugins/snacks.lua:31-56` provides `opts`, so lazy.nvim's default plugin config path is relevant. lazy.nvim docs say `opts` is passed to `Plugin.config()` and implies `Plugin.config()`; the default implementation runs `require(MAIN).setup(opts)` (`lazy.nvim.txt:301-310`).

- `lua/config/lazy.lua:25-29` imports plugin specs from `lua/plugins/`:

```lua
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
```

- `lazy-lock.json:5-6,28` currently pins:
  - `bufdelete.nvim` commit `f6bcea78afb3060b198125256f897040538bcb81`
  - `bufferline.nvim` commit `655133c3b4c3e5e05ec549b9f8cc2894ac6f51b3`
  - `snacks.nvim` commit `882c996cf28183f4d63640de0b4c02ec886d01f2`

#### Snacks.bufdelete API and behavior

- Installed Snacks docs define the option shape at `snacks.nvim/docs/bufdelete.md:10-19` and source annotations match at `snacks.nvim/lua/snacks/bufdelete.lua:13-18`:

```lua
---@class snacks.bufdelete.Opts
---@field buf? number Buffer to delete. Defaults to the current buffer
---@field file? string Delete buffer by file name. If provided, `buf` is ignored
---@field force? boolean Delete the buffer even if it is modified
---@field filter? fun(buf: number): boolean Filter buffers to delete
---@field wipe? boolean Wipe the buffer instead of deleting it (see `:h :bwipeout`)
```

- `Snacks.bufdelete` itself is callable because `snacks.nvim/lua/snacks/bufdelete.lua:1-7` wraps the module in a metatable whose `__call` delegates to `M.delete(...)`:

```lua
local M = setmetatable({}, {
  __call = function(t, ...)
    return t.delete(...)
  end,
})
```

- The docs expose these entry points:
  - `Snacks.bufdelete()` as `fun(buf?: number|snacks.bufdelete.Opts)` (`docs/bufdelete.md:21-28`)
  - `Snacks.bufdelete.delete(opts)` (`docs/bufdelete.md:39-49`)
  - `Snacks.bufdelete.all(opts)` (`docs/bufdelete.md:30-37`)
  - `Snacks.bufdelete.other(opts)` (`docs/bufdelete.md:60-67`)
  - installed version also has `Snacks.bufdelete.invisible(opts)` (`docs/bufdelete.md:51-58`; source `bufdelete.lua:114-122`)

- `Snacks.bufdelete.delete(opts)` accepts either a number or an opts table. Source `bufdelete.lua:25-29` converts a number to `{ buf = opts }`:

```lua
opts = opts or {}
opts = type(opts) == "number" and { buf = opts } or opts
opts = type(opts) == "function" and { filter = opts } or opts
```

- Buffer selection behavior:
  - With no `buf`, `buf` starts as `0`, then resolves to `vim.api.nvim_get_current_buf()` (`bufdelete.lua:40-47`).
  - With `{ buf = bufnr }`, it deletes that buffer number (`bufdelete.lua:40-47`).
  - With `{ file = path }`, `file` overrides `buf` via `vim.fn.bufnr(opts.file)` (`bufdelete.lua:41-46`).
  - Invalid buffers return without error (`bufdelete.lua:49-51`).

- Non-force behavior is not the same implementation path as plain `:bdelete`. If `vim.bo[buf].modified` and `opts.force` is not set, Snacks prompts `Save changes to ...?` with Yes/No/Cancel (`bufdelete.lua:53-61`):
  - Cancel/Esc returns without deleting (`bufdelete.lua:55-57`).
  - Yes writes the buffer before delete (`bufdelete.lua:58-60`).
  - No proceeds to deletion after the prompt (`bufdelete.lua:55-61`, then `bufdelete.lua:86-90`).

- Force behavior bypasses the modified-buffer prompt because the prompt block is guarded by `vim.bo[buf].modified and not opts.force` (`bufdelete.lua:53-55`). The final delete command is still bang-form internally:

```lua
pcall(vim.cmd, (opts.wipe and "bwipeout! " or "bdelete! ") .. buf)
```

  This is at `bufdelete.lua:86-90`, with temporary `eventignore = "DiagnosticChanged"` around the delete.

- Layout-preserving behavior happens before deletion: Snacks gathers the most recently used listed buffer (`bufdelete.lua:63-73`), then replaces every window showing the deleted buffer with the alternate buffer when possible or a fallback listed buffer/new buffer (`bufdelete.lua:75-84`).

- Snacks global API: `snacks.nvim/lua/snacks/init.lua:4-12` sets a metatable that loads `require("snacks." .. k)` on first field access and assigns `_G.Snacks = M`. Therefore `Snacks.bufdelete` resolves through the global `Snacks` table once `require("snacks")` has run.

#### Bufferline close_command function signature and call path

- Bufferline docs show `close_command`, `right_mouse_command`, `left_mouse_command`, and `middle_mouse_command` can be string/function/false (`bufferline.txt:70-77`). The current default examples are `"bdelete! %d"` and `"buffer %d"`.

- Bufferline type annotations are less precise but confirm close/mouse command values accept functions:
  - `types.lua:33`: `---@field public close_command? string | function`
  - `types.lua:35-37`: left/right/middle mouse commands are also `string | function` variants.

- The implementation proves the function receives the buffer/tab id as one numeric argument. `commands.lua:36-49`:

```lua
---@param command string|function
---@param id number
local function handle_user_command(command, id)
  if not command then return end
  if type(command) == "function" then
    command(id)
  elseif type(command) == "string" then
    vim.schedule(function()
      vim.cmd(fmt(command, id))
      ui.refresh()
    end)
  end
end
```

- Close icon / pick-close path: `handle_close(id)` reads `config.options.close_command` and passes `(close, id)` to `handle_user_command` (`commands.lua:58-63`). `M.close_with_pick()` also calls `handle_close(id)` after selection (`commands.lua:103-105`).

- Mouse right-click path: click handlers map `r` to `right_mouse_command`, then pass the clicked buffer id into `handle_user_command(options[cmds[button]], id)` (`commands.lua:80-91`).

- Bufferline bulk-close commands use `close_command` for each buffer id. Source `commands.lua:229-244` loops visible components left/right and calls `delete_element(item.id)`, which reaches `handle_close(id)` in buffer mode (`commands.lua:65-72`). Docs state `BufferLineCloseRight`, `BufferLineCloseLeft`, and `BufferLineCloseOthers` apply the configured `close_command` to each corresponding buffer (`bufferline.txt:555-567`).

- Bufferline docs include a function example for a close/mouse command at `bufferline.txt:699-706`:

```lua
left_mouse_command = function(bufnum)
    require('bufdelete').bufdelete(bufnum, true)
end
```

  The example uses `bufnum` as the single parameter, matching the implementation's `command(id)` call.

#### Dependency edge from Bufferline to Snacks

- Current project facts:
  - `snacks.nvim` is a start plugin via `lazy = false` (`lua/plugins/snacks.lua:1-4`).
  - `bufferline.nvim` is lazy-loaded on `event = 'VimEnter'` (`lua/plugins/bufferline.lua:41-47`).
  - lazy.nvim imports both specs from `lua/plugins/` (`lua/config/lazy.lua:25-29`).

- lazy.nvim startup docs state all plugin `init()` functions run first, then all plugins with `lazy=false` are loaded (`lazy.nvim.txt:967-970`). That places `folke/snacks.nvim` loading before a `VimEnter`-triggered Bufferline config under the current spec.

- lazy.nvim docs define `dependencies` as plugin specs loaded when the plugin loads, and note dependencies are always lazy-loaded unless specified otherwise (`lazy.nvim.txt:273-276`). The same docs advise: only use `dependencies` if a plugin needs the dependency to be installed and loaded; Lua plugins/libraries are automatically loaded when `require()`d (`lazy.nvim.txt:1299-1301`).

- Because the current replacement target is a call to global `Snacks.bufdelete`, and `Snacks` is created when the eagerly-loaded Snacks plugin module initializes (`snacks/init.lua:4-12`), a Bufferline-to-Snacks dependency edge is not required under the current `lazy = false` Snacks setup. This matches the task PRD's technical approach (`.trellis/tasks/05-27-bufferline-bufdelete/prd.md:48-50`).

### External References

- [folke/snacks.nvim docs/bufdelete.md](https://github.com/folke/snacks.nvim/blob/main/docs/bufdelete.md) — documents `Snacks.bufdelete()`, `Snacks.bufdelete.delete(opts)`, `all`, `other`, and opts fields (`buf`, `file`, `force`, `filter`, `wipe`).
- [folke/snacks.nvim lua/snacks/bufdelete.lua](https://github.com/folke/snacks.nvim/blob/main/lua/snacks/bufdelete.lua) — source for force/non-force prompt behavior, window replacement, and final `bdelete!`/`bwipeout!` call.
- [akinsho/bufferline.nvim doc/bufferline.txt](https://github.com/akinsho/bufferline.nvim/blob/main/doc/bufferline.txt) — documents Bufferline close/mouse command values and the function-form mouse action example.
- [akinsho/bufferline.nvim lua/bufferline/commands.lua at pinned commit](https://github.com/akinsho/bufferline.nvim/blob/655133c3/lua/bufferline/commands.lua) — source for `handle_user_command(command, id)` and close command propagation.
- [lazy.nvim lazy-loading docs](https://lazy.folke.io/spec/lazy_loading) — documents lazy-loading triggers and `lazy=false` start plugin behavior.
- [lazy.nvim spec docs](https://github.com/folke/lazy.nvim/blob/main/doc/lazy.nvim.txt) — documents `opts`, `dependencies`, `priority`, `lazy=false` startup order, and dependency guidance.

### Related Specs

- `.trellis/tasks/05-27-bufferline-bufdelete/prd.md:25-31` — task requirements: remove `famiu/bufdelete.nvim`; use `Snacks.bufdelete({ buf = bufnr, force = true })` for Bufferline close/right-click; use `Snacks.bufdelete()` for `<leader>bd`; keep other Bufferline behavior unchanged.
- `.trellis/tasks/05-27-bufferline-bufdelete/prd.md:33-46` — acceptance criteria and definition of done, including Neovim headless config load and Bufferline forced-load checks.
- `.trellis/spec/backend/quality-guidelines.md:32-34` — project convention: lazy.nvim plugin specs live under `lua/plugins/`, return a spec table directly, and keymaps in plugin `keys` entries should include user-facing `desc`.
- `.trellis/spec/backend/quality-guidelines.md:46-48` — project check guidance: run Neovim headless startup check when available; otherwise Lua syntax/manual checks.
- `.trellis/spec/frontend/type-safety.md:73-77` — convention: do not access optional plugin APIs without guarding availability when startup can run before that plugin/tool exists.

## Caveats / Not Found

- No runtime verification was performed in this research step; code was not modified.
- No direct `Snacks.bufdelete` usage currently exists in project config files. Grep found only current `bdelete` strings in `lua/plugins/bufferline.lua` and task notes under `.trellis/tasks/05-27-bufferline-bufdelete/prd.md`.
- `Snacks.bufdelete()` non-force behavior prompts on modified buffers and can discard changes if the user chooses `No`; plain `:bdelete` usually refuses modified buffers. This is a behavior difference to account for when interpreting “non-force” semantics.
- The “no Bufferline dependency edge needed” conclusion depends on `lua/plugins/snacks.lua` continuing to keep `folke/snacks.nvim` as `lazy = false` and on using the global `Snacks` API after Snacks has loaded. If Snacks startup strategy changes, this ordering should be rechecked.
