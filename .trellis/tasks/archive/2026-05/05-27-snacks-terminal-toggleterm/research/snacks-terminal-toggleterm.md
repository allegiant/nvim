# Research: Snacks terminal replacement for ToggleTerm

- **Query**: Research replacing `akinsho/toggleterm.nvim` with `Snacks.terminal` in this Neovim config. Focus on Snacks terminal API/options; implementing `<C-\\>` toggle, `<leader>tn` new terminal, `<leader>ts` select existing terminal with `vim.ui.select`; preserving Windows shell options; scoping terminal-mode keymaps to Snacks terminal only; whether to delete or repurpose `toggleterm.lua`; verification commands.
- **Scope**: mixed (internal config + installed plugin docs/source + web references)
- **Date**: 2026-05-27

## Findings

### Files Found

| File Path | Description |
|---|---|
| `lua/plugins/toggleterm.lua` | Current ToggleTerm plugin spec, Windows PowerShell shell options, terminal-mode keymaps, `<leader>t*` mappings, `<C-\\>` open mapping, horizontal size 10. |
| `lua/plugins/snacks.lua` | Existing `folke/snacks.nvim` spec with `lazy = false`, picker/dashboard/notifier opts, and existing Snacks keymaps. |
| `lua/plugins/claudecode.lua` | Claude Code terminal-specific `<Esc>` mapping logic; must remain isolated from generic terminal keymaps. |
| `lua/plugins/overseer.lua` | Uses `strategy = { "toggleterm", direction = 'vertical' }`, so ToggleTerm removal has an additional internal reference. |
| `lua/config/lazy.lua` | Imports all modules under `lua/plugins` through `{ import = "plugins" }`. |
| `lazy-lock.json` | Currently pins both `snacks.nvim` (`882c996c...`) and `toggleterm.nvim` (`9a88eae...`). |
| `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/docs/terminal.md` | Installed Snacks terminal docs for config, styles, options, and module functions. |
| `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/terminal.lua` | Installed Snacks terminal implementation; confirms `list`, `open`, `toggle`, `focus`, id behavior, shell behavior, buffer metadata. |
| `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/win.lua` | Installed Snacks window implementation; confirms `snacks.win` instances expose `show`, `focus`, `hide`, `toggle`. |
| `C:/Users/alleg/AppData/Local/nvim-data/lazy/overseer.nvim/doc/strategies.md` | Installed Overseer strategy docs; current docs list `jobstart`, `orchestrator`, `system`, `test`, not `toggleterm`. |
| `C:/Users/alleg/AppData/Local/nvim-data/lazy/overseer.nvim/CHANGELOG.md` | Notes removal of `toggleterm` and `terminal` strategies. |
| `C:/Users/alleg/AppData/Local/nvim-data/lazy/lazy.nvim/doc/lazy.nvim.txt` | Installed lazy.nvim docs for spec merging and duplicate specs for the same plugin. |

### Code Patterns

#### Current ToggleTerm ownership

`lua/plugins/toggleterm.lua` currently does more than declare the ToggleTerm plugin:

- Windows shell options are set at file top-level before the plugin spec is returned (`lua/plugins/toggleterm.lua:1-17`). These include `shell`, `shellcmdflag`, `shellredir`, `shellpipe`, `shellquote`, and `shellxquote`.
- Terminal-mode keymaps are installed by a global function (`_G.set_terminal_keymaps`) with buffer-local mappings for `<esc>`, `jk`, and `<C-h/j/k/l>` (`lua/plugins/toggleterm.lua:19-27`).
- ToggleTerm registers the plugin and keymaps for `<leader>t`, `<leader>tn`, `<leader>ts` (`lua/plugins/toggleterm.lua:29-35`).
- ToggleTerm setup uses `open_mapping = [[<c-\\>]]`, `direction = 'horizontal'`, and horizontal `size = 10` (`lua/plugins/toggleterm.lua:37-47`).
- Terminal mappings are scoped to ToggleTerm buffers using `term://*toggleterm#*`, not all terminal buffers (`lua/plugins/toggleterm.lua:75`).

Implication: deleting this file without moving its non-plugin responsibilities would remove Windows shell configuration and terminal-mode keymap behavior.

#### Existing Snacks setup

`lua/plugins/snacks.lua` already returns a `folke/snacks.nvim` lazy spec (`lua/plugins/snacks.lua:1-4`):

- `priority = 1000` and `lazy = false` mean Snacks is an always-loaded plugin in this config (`lua/plugins/snacks.lua:1-4`).
- Existing Snacks keymaps live in the same spec under `keys` (`lua/plugins/snacks.lua:5-33`).
- Existing `opts` enables `dashboard`, `input`, `picker`, and `notifier`; it does not currently include `terminal` (`lua/plugins/snacks.lua:34-59`).
- Existing `init` contains a plugin-specific `LspProgress` autocmd using Snacks notifier behavior (`lua/plugins/snacks.lua:60-102`).

This makes `lua/plugins/snacks.lua` a natural internal location for Snacks-owned terminal opts/keymaps if the project wants one file per plugin.

#### Claude Code terminal isolation

`lua/plugins/claudecode.lua` installs `<Esc>` only when the buffer is the active Claude Code terminal:

- It first checks `vim.bo[bufnr].buftype == "terminal"` (`lua/plugins/claudecode.lua:1-4`).
- It requires `claudecode.terminal` and uses `terminal.get_active_terminal_bufnr()` (`lua/plugins/claudecode.lua:6-12`).
- Only that buffer receives the buffer-local terminal-mode `<Esc>` mapping (`lua/plugins/claudecode.lua:15-18`).
- The autocmd covers `TermOpen`, `TermEnter`, and `BufEnter`, but the callback re-checks the active Claude terminal before mapping (`lua/plugins/claudecode.lua:28-36`).

Implication: any broad `TermOpen term://*` terminal-mode mapping would add keymaps to Claude Code terminal buffers and conflict with this file's deliberate scoping.

#### Additional ToggleTerm reference outside `toggleterm.lua`

`lua/plugins/overseer.lua` configures Overseer with a ToggleTerm strategy (`lua/plugins/overseer.lua:10-14`):

```lua
strategy = {
  "toggleterm",
  direction = 'vertical',
},
```

Installed Overseer docs say the current strategy docs list `jobstart`, `orchestrator`, `system`, and `test` (`C:/Users/alleg/AppData/Local/nvim-data/lazy/overseer.nvim/doc/strategies.md:1-10`). Installed changelog notes "remove toggleterm and terminal strategies" (`C:/Users/alleg/AppData/Local/nvim-data/lazy/overseer.nvim/CHANGELOG.md:60-68`). Installed strategy files are only `init.lua`, `test.lua`, `orchestrator.lua`, `jobstart.lua`, and `system.lua` under `lua/overseer/strategy/`.

This is a critical internal reference to account for when removing the ToggleTerm dependency.

### Snacks terminal API and options

Installed Snacks terminal docs/source confirm the following API surface and behavior.

#### Setup and defaults

- Terminal config lives under `opts.terminal` in the Snacks lazy spec (`C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/docs/terminal.md:43-58`).
- `snacks.terminal.Config` supports:
  - `win?: snacks.win.Config|{}`
  - `shell?: string|string[]` (defaults to `vim.o.shell`)
  - `override?: fun(cmd?, opts?)` (`docs/terminal.md:60-69`; source `terminal.lua:15-21`).
- With no `cmd`, Snacks opens the terminal in a bottom split; with `cmd`, it opens a floating window (`docs/terminal.md:5-9`; source `terminal.lua:88-96`).
- Default terminal style sets `bo.filetype = "snacks_terminal"`, `stack = true`, and default keys including `q = "hide"`, `gf`, and `term_normal` for double-escape normal mode (`docs/terminal.md:77-116`; source `terminal.lua:32-68`).
- `snacks.terminal.Opts` supports `cwd`, `count`, `env`, `start_insert`, `auto_insert`, `auto_close`, and `interactive` (`docs/terminal.md:119-130`; source `terminal.lua:23-30`).

#### Terminal identity and lifecycle

- `Snacks.terminal` is callable and delegates to `toggle` (`terminal.lua:1-9`; docs `terminal.md:141-146`).
- `Snacks.terminal.open(cmd, opts)` opens a new terminal window (`docs/terminal.md:194-202`; source `terminal.lua:85-171`).
- `Snacks.terminal.tid(cmd, opts)` computes the terminal id from `cmd`, `cwd`, `env`, and `count`/`vim.v.count1` (`terminal.lua:173-183`; docs `terminal.md:204-212`).
- `Snacks.terminal.get(cmd, opts)` gets or creates a terminal and defaults `opts.create` to `true` (`terminal.lua:186-205`; docs `terminal.md:174-185`).
- `Snacks.terminal.list()` returns valid `snacks.win[]` terminal windows (`terminal.lua:207-212`; docs `terminal.md:187-192`).
- `Snacks.terminal.toggle(cmd, opts)` uses `get`; if the terminal was newly created it returns it, otherwise it toggles the existing window (`terminal.lua:214-220`; docs `terminal.md:214-223`).
- `Snacks.terminal.focus(cmd, opts)` hides the terminal if already focused; otherwise it shows and focuses it (`terminal.lua:223-234`; docs `terminal.md:163-172`).
- Each opened Snacks terminal buffer receives `vim.b[buf].snacks_terminal = { cmd = cmd, id = id, cwd = opts.cwd, env = opts.env }` before user `on_buf` is called (`terminal.lua:107-115`).
- `Snacks.terminal.open` starts the job with `cmd or M.parse(opts.shell or vim.o.shell)` and passes `cwd`, `env`, and `term = true` (`terminal.lua:160-166`).

#### Window methods available on selected terminals

`Snacks.terminal.list()` returns `snacks.win` instances. Installed `snacks.win` source confirms these methods:

- `win:focus()` sets current window when valid (`win.lua:503-507`).
- `win:hide()` closes the window but keeps the buffer (`win.lua:619-622`).
- `win:toggle()` hides if valid, otherwise shows (`win.lua:624-630`).
- `win:show()` opens/updates the window and calls `opts.on_buf` before `opts.on_win` (`win.lua:819-840`, `win.lua:862-873`).

This supports selecting an item from `Snacks.terminal.list()` and focusing it via `term:show():focus()`.

### Implementation shape for required mappings

The following is the researched implementation shape, not an applied code change.

#### Shared terminal opts

To mimic the current ToggleTerm horizontal split height, Snacks can use terminal window opts similar to:

```lua
local terminal_opts = {
  win = {
    position = "bottom",
    height = 10,
  },
}
```

Reasoning: Snacks defaults no-`cmd` terminals to bottom split, and `snacks.win.Config` supports `position` plus `height` (`snacks.nvim/docs/terminal.md:5-9`; `snacks.nvim/docs/win.md` search results show `height` and `position` fields; source `terminal.lua:91-96` resolves `position = cmd and "float" or "bottom"`).

#### `<C-\\>` toggle

`Snacks.terminal.toggle(nil, terminal_opts)` maps directly to the current single/default terminal behavior. Because terminal identity includes `count`/`vim.v.count1`, the default no-count toggle uses count 1 (`terminal.lua:173-183`, `terminal.lua:214-220`).

Mapping modes to consider for parity with ToggleTerm open mapping:

```lua
{ "<C-\\>", function() Snacks.terminal.toggle(nil, terminal_opts) end, mode = { "n", "t" }, desc = "Toggle Terminal" }
```

`mode = { "n", "t" }` preserves toggle access from normal and terminal mode; if only normal mode is wanted, omit `"t"`.

#### `<leader>tn` create new terminal

`Snacks.terminal.open(nil, opts)` always opens a new terminal, but the registry key uses `count`. If repeated `open(nil, { count = 1 })` is used, the internal `terminals[tid]` entry for count 1 is overwritten (`terminal.lua:128-130`, `terminal.lua:173-183`), which means older terminals can fall out of `Snacks.terminal.list()` even if buffers/windows still exist.

For `<leader>tn` to create terminals that remain selectable with `Snacks.terminal.list()`, give each new terminal a distinct `count`, for example by maintaining a local incrementing counter:

```lua
local next_terminal_count = 1

local function new_terminal()
  next_terminal_count = next_terminal_count + 1
  Snacks.terminal.open(nil, vim.tbl_deep_extend("force", terminal_opts, {
    count = next_terminal_count,
  }))
end
```

This leaves the default `<C-\\>` terminal at count 1 and gives newly-created terminals count 2, 3, ... . If count prefixes are intended as user-facing terminal ids, the API already uses `vim.v.count1` when `opts.count` is omitted (`terminal.lua:173-183`).

#### `<leader>ts` select existing terminal with `vim.ui.select`

`Snacks.terminal.list()` returns valid terminal windows (`terminal.lua:207-212`), and each has `buf` plus Snacks terminal metadata in `vim.b[buf].snacks_terminal` (`terminal.lua:107-115`). A selection callback can show and focus the selected terminal via `term:show():focus()` because `snacks.win` provides both methods (`win.lua:503-507`, `win.lua:819-840`).

Implementation shape:

```lua
local function select_terminal()
  local terminals = Snacks.terminal.list()
  if vim.tbl_isempty(terminals) then
    vim.notify("No Snacks terminals", vim.log.levels.INFO)
    return
  end

  vim.ui.select(terminals, {
    prompt = "Select terminal",
    format_item = function(term)
      local meta = vim.b[term.buf].snacks_terminal or {}
      local title = vim.b[term.buf].term_title or vim.api.nvim_buf_get_name(term.buf)
      return ("%s: %s"):format(meta.id or term.buf, title)
    end,
  }, function(term)
    if term then
      term:show():focus()
    end
  end)
end
```

`lua/plugins/snacks.lua` currently has `picker = { enabled = true }` (`lua/plugins/snacks.lua:48-49`). Installed Snacks picker docs show `ui_select = true` by default in picker config (`snacks.nvim/docs/picker.md:145-149`), so `vim.ui.select` should use Snacks picker when Snacks picker has set the UI override. The implementation can still call plain `vim.ui.select`; it does not need to call a Snacks-specific picker API directly.

### Preserving Windows shell options

Current Windows shell options exist only in `lua/plugins/toggleterm.lua:1-17` based on search results. `lua/core/options.lua` has Windows clipboard PowerShell commands but no equivalent shell option setup (`lua/core/options.lua:123-127` from grep output).

Snacks terminal shell behavior:

- `snacks.terminal.Config.shell` defaults to `vim.o.shell` (`terminal.md:63-69`; `terminal.lua:15-18`).
- Terminal process startup uses `cmd or M.parse(opts.shell or vim.o.shell)` (`terminal.lua:160-166`).

Therefore, preserving the existing Windows shell setup means keeping these `vim.opt.shell*` assignments in an always-loaded location after removing the ToggleTerm plugin spec. Possible loaded locations observed in this config:

- `lua/core/options.lua`, loaded before lazy.nvim from `init.lua:7-10`.
- `lua/plugins/snacks.lua` `init` or top-level code, because Snacks is `lazy = false` (`lua/plugins/snacks.lua:1-4`), but this would couple global shell options to the Snacks plugin file.
- A repurposed `lua/plugins/toggleterm.lua` file that no longer returns `akinsho/toggleterm.nvim`, if the project wants terminal UI ownership to stay in a terminal-named plugin module.

### Scoping terminal-mode keymaps to Snacks terminal only

Scoped options found in Snacks:

- Default Snacks terminal filetype is `snacks_terminal` (`terminal.lua:32-35`; `terminal.md:79-83`).
- Snacks terminal sets `vim.b[buf].snacks_terminal` for each terminal buffer before invoking any user `win.on_buf` callback (`terminal.lua:107-115`).
- `snacks.win.Config` supports `on_buf` callback after opening the buffer (`snacks.nvim/docs/win.md` search result lines 70-72; source `win.lua:839-840`).

Two scoped implementation mechanisms are supported by these facts:

1. Use `opts.terminal.win.on_buf` to install buffer-local terminal-mode mappings. This is the narrowest scope because it runs only for Snacks terminal windows and after `b:snacks_terminal` is set.
2. Use a `FileType` autocmd with `pattern = "snacks_terminal"`. This is also scoped to Snacks terminal style, but it is broader than `on_buf` if another buffer manually uses that filetype.

Avoid a broad `TermOpen term://*` pattern. Project spec explicitly records that terminal hooks should be scoped and says ToggleTerm mappings should use `term://*toggleterm#*`, not broad `term://*`, so Claude Code and other terminals do not inherit ToggleTerm-only `<Esc>` behavior (`.trellis/spec/frontend/hook-guidelines.md:69-70`).

A scoped `on_buf` mapping shape:

```lua
local function set_snacks_terminal_keymaps(bufnr)
  local opts = { buffer = bufnr }
  vim.keymap.set("t", "<Esc>", [[<C-\\><C-n>]], opts)
  vim.keymap.set("t", "jk", [[<C-\\><C-n>]], opts)
  vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
  vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
  vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
  vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
end

-- Inside terminal opts:
win = {
  position = "bottom",
  height = 10,
  on_buf = function(term)
    set_snacks_terminal_keymaps(term.buf)
  end,
}
```

Default Snacks terminal already has a terminal-mode `<Esc>` mapping named `term_normal`, but it requires double escape to stop insert (`terminal.lua:51-66`). If current single-escape behavior is required, a buffer-local `<Esc>` map in `on_buf` would replace the effective behavior for Snacks terminal buffers only.

### Delete vs repurpose `lua/plugins/toggleterm.lua`

Facts from internal config and lazy.nvim docs:

- `lua/config/lazy.lua` imports all plugin specs from `lua/plugins` (`lua/config/lazy.lua:25-29`).
- `lua/plugins/snacks.lua` already declares the `folke/snacks.nvim` spec (`lua/plugins/snacks.lua:1-4`).
- lazy.nvim docs state `opts` should be a table that is merged with parent specs (`lazy.nvim/doc/lazy.nvim.txt:301-305`).
- lazy.nvim docs state that adding a spec for the same plugin can override/merge, and `opts`, `dependencies`, `cmd`, `event`, `ft`, and `keys` are always merged with the parent spec (`lazy.nvim/doc/lazy.nvim.txt:1272-1276`).

Observed options:

1. Delete `lua/plugins/toggleterm.lua` and move its non-ToggleTerm responsibilities elsewhere.
   - Must preserve Windows shell options from `toggleterm.lua:1-17`.
   - Must recreate terminal keymaps scoped to Snacks terminal only.
   - Must ensure no `akinsho/toggleterm.nvim` spec remains.

2. Repurpose `lua/plugins/toggleterm.lua` as terminal UI ownership without registering ToggleTerm.
   - It can return an additional `folke/snacks.nvim` spec with terminal `keys`/`opts`; lazy.nvim merges `keys` and `opts` for same-plugin specs.
   - Non-merged fields such as `config` would override rather than merge, so a repurposed file should avoid conflicting `config` for Snacks unless intentionally replacing the existing Snacks config.
   - The filename itself does not determine plugin identity; the returned spec does.

3. Move all terminal-related Snacks config into `lua/plugins/snacks.lua`.
   - This keeps one spec per plugin and matches existing Snacks key ownership.
   - It increases the responsibility of `snacks.lua` beyond picker/dashboard/notifier to include terminal.

Current `lazy-lock.json` still includes `toggleterm.nvim` (`lazy-lock.json:29`). Removing the plugin spec from `lua/plugins` prevents registration; lockfile cleanup is a separate dependency-maintenance step, typically performed by lazy.nvim tooling.

### Related Specs

| Spec Path | Relevant Contract |
|---|---|
| `.trellis/spec/frontend/directory-structure.md` | Treats this repo's frontend layer as editor-facing surface; plugin-owned mappings/options belong in `lua/plugins/*.lua` (`lines 7-15`, `lines 40-42`). Lists `lua/plugins/toggleterm.lua` as current terminal UI/shell owner (`lines 23-29`). |
| `.trellis/spec/frontend/hook-guidelines.md` | Plugin-specific autocommands belong with the plugin (`line 49`). Terminal hooks must be scoped; avoid broad terminal patterns that affect Claude Code (`lines 69-70`). |
| `.trellis/spec/frontend/component-guidelines.md` | Use lazy.nvim spec shape; prefer `opts` when declarative and `config` only when setup logic is needed (`lines 20-39`). Add `desc` to lazy key entries and group related leader mappings (`lines 64-69`). |
| `.trellis/spec/guides/code-reuse-thinking-guide.md` | Search first and reuse existing patterns before writing new code (`lines 18-38`). |

### External References

- [Snacks terminal docs](https://github.com/folke/snacks.nvim/blob/main/docs/terminal.md) — documents config, default bottom/float behavior, `shell`, `win`, `open`, `toggle`, `focus`, `get`, and `list`.
- [Snacks terminal source](https://github.com/folke/snacks.nvim/blob/main/lua/snacks/terminal.lua) — confirms terminal id and `b:snacks_terminal` metadata behavior.
- [Snacks keymap docs](https://github.com/folke/snacks.nvim/blob/main/docs/keymap.md) — documents Snacks keymap helper, including filetype-specific keymap support; local implementation can also use plain `vim.keymap.set` with buffer scoping.
- [lazy.nvim plugin spec docs](https://lazy.folke.io/spec) — documents `opts` behavior and spec properties; local installed docs confirm same-plugin `opts`/`keys` merge.
- [Overseer strategies docs](https://github.com/stevearc/overseer.nvim/blob/master/doc/strategies.md) — current strategies are `jobstart`, `orchestrator`, `system`, and `test`; relevant because `lua/plugins/overseer.lua` names `toggleterm`.

### Verification Commands

Run from `C:\Users\alleg\AppData\Local\nvim` after implementation.

#### Config loads

```powershell
nvim --headless "+lua print('config ok')" +qa
```

#### Snacks terminal API is available

```powershell
nvim --headless "+lua assert(Snacks and Snacks.terminal, 'Snacks.terminal missing'); for _, name in ipairs({'toggle','open','list','focus'}) do assert(type(Snacks.terminal[name]) == 'function', name .. ' missing') end" +qa
```

#### ToggleTerm is no longer registered by lazy.nvim

```powershell
nvim --headless "+lua local plugins=require('lazy.core.config').plugins; assert(not plugins['toggleterm.nvim'], 'toggleterm.nvim still registered')" +qa
```

#### Windows shell options still exist

```powershell
nvim --headless "+set shell? shellcmdflag? shellredir? shellpipe? shellquote? shellxquote?" +qa
```

#### Snacks health check

```powershell
nvim --headless "+checkhealth snacks" +qa
```

#### Manual interactive checks

1. Start normal Neovim and press `<C-\\>`: default Snacks terminal toggles in a bottom split.
2. Press `<leader>tn` multiple times: each invocation creates an additional terminal that remains discoverable by `Snacks.terminal.list()`.
3. Press `<leader>ts`: `vim.ui.select` lists existing terminals and focusing a selected terminal shows/focuses it.
4. In a Snacks terminal, verify `<Esc>`, `jk`, and `<C-h/j/k/l>` terminal-mode behavior.
5. Open Claude Code (`<leader>ac`) and verify its terminal `<Esc>` behavior remains governed by `lua/plugins/claudecode.lua`, not by Snacks terminal keymaps.
6. Run an Overseer task if that workflow is used; `lua/plugins/overseer.lua` currently names the `toggleterm` strategy.

## Caveats / Not Found

- No existing `Snacks.terminal` usage was found in the repo; implementation will be new to this config.
- `lua/plugins/overseer.lua` is an additional ToggleTerm-related reference. Current installed Overseer docs/source do not include a `toggleterm` strategy file, and the changelog says ToggleTerm/terminal strategies were removed. This is a critical caveat for ToggleTerm removal even though it is outside `lua/plugins/toggleterm.lua`.
- `Snacks.terminal.open(nil, opts)` without a unique `count` can overwrite the internal registry entry for the same terminal id; use distinct counts if `<leader>tn` must create terminals that remain selectable through `Snacks.terminal.list()`.
- Snacks default terminal `<Esc>` behavior is double-escape normal mode. Current ToggleTerm config uses single `<Esc>` and `jk`; preserving that behavior requires scoped buffer-local maps or terminal style key overrides.
- The research did not modify code and did not run post-change verification commands because the implementation has not been applied.
