# Research: Snacks.nvim explorer migration from nvim-tree

- **Query**: Research Snacks.nvim explorer usage and configuration needed to replace nvim-tree in a Neovim lazy.nvim config. Focus on: enabling explorer, toggle/open keymap API, filetype/buffer name used by the explorer for integrations such as bufferline offsets and claudecode tree-add mappings, dotfile visibility, git/diagnostic/watch behavior parity, and any migration pitfalls from nvim-tree.
- **Scope**: mixed
- **Date**: 2026-06-05

## Findings

### Files Found

| File Path | Description |
|---|---|
| `lua/plugins/snacks.lua` | Current `folke/snacks.nvim` lazy.nvim spec; Snacks is eager-loaded, picker is enabled, and explorer is currently disabled at line 57. Existing Snacks keymaps are in this file. |
| `lua/plugins/nvimtree.lua` | Current `nvim-tree/nvim-tree.lua` spec; owns `<leader>e`, shows dotfiles, disables git and diagnostics, and enables filesystem watchers with ignore directories. |
| `lua/plugins/bufferline.lua` | Current bufferline offset points at filetype `NvimTree` at line 30. |
| `lua/plugins/claudecode.lua` | Current `ClaudeCodeTreeAdd` keymap is scoped to `NvimTree`, `neo-tree`, `oil`, `minifiles`, and `netrw` at line 21. |
| `lazy-lock.json` | Pins `bufferline.nvim`, `claudecode.nvim`, `nvim-tree.lua`, and `snacks.nvim`; current Snacks lock entry is commit `882c996cf28183f4d63640de0b4c02ec886d01f2`. |
| `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/docs/explorer.md` | Local installed Snacks explorer docs for setup, navigation, git/diagnostics, config, and module API. |
| `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/explorer/init.lua` | Explorer module implementation: defaults, netrw replacement setup, `open()`, and `reveal()`. |
| `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/picker/init.lua` | Picker entrypoint; opening the same source closes the existing picker, which gives `Snacks.explorer()` toggle-like behavior. |
| `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/picker/config/sources.lua` | Explorer picker defaults: `watch`, `diagnostics`, `git_status`, `hidden`/`ignored` inherited from files config, and explorer keymaps. |
| `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/picker/core/list.lua` | Picker list window buffer filetype is `snacks_picker_list`. |
| `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/picker/core/input.lua` | Picker input buffer filetype is `snacks_picker_input`, buftype `prompt`. |
| `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/layout.lua` | Picker layout box buffer filetype is `snacks_layout_box`, buftype `nofile`; this is the filetype used by reported working bufferline offsets. |
| `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/picker/source/explorer.lua` | Explorer source implementation for watch hooks, diagnostics updates, follow-file, git updates, item fields, search mode, and hidden status. |
| `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/explorer/tree.lua` | Tree state and filter implementation; hidden/ignored/exclude/include filtering and close-all behavior. |
| `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/explorer/watch.lua` | File watcher implementation; watches git index and open directories, refreshes through a fixed timer. |
| `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/explorer/git.lua` | Git status implementation; runs `git status --porcelain=v1 --ignored=matching -z` with tracked/untracked behavior. |
| `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/explorer/diagnostics.lua` | Diagnostic aggregation implementation; reads all Neovim diagnostics and propagates severity to parent directories. |
| `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/explorer/actions.lua` | Explorer actions for focus, up, close, refresh, git/diagnostic next/prev, file operations, and confirm behavior. |
| `C:/Users/alleg/AppData/Local/nvim-data/lazy/claudecode.nvim/lua/claudecode/integrations.lua` | `ClaudeCodeTreeAdd` integration support list and file selection logic; no Snacks picker/explorer branch exists in the installed plugin. |

### Current Project State

Current Snacks config:

```lua
-- lua/plugins/snacks.lua:45-68
opts = {
  -- ...
  explorer = { enabled = false },
  -- ...
  picker = { enabled = true },
}
```

Relevant lines:

- `lua/plugins/snacks.lua:5-7` loads `folke/snacks.nvim` eagerly with `lazy = false`.
- `lua/plugins/snacks.lua:18-22` already maps picker file commands through `Snacks.picker.*`.
- `lua/plugins/snacks.lua:57` explicitly disables Snacks explorer.
- `lua/plugins/snacks.lua:68` enables Snacks picker.

Current nvim-tree config:

- `lua/plugins/nvimtree.lua:2` declares `nvim-tree/nvim-tree.lua`.
- `lua/plugins/nvimtree.lua:5` maps `<leader>e` to `<cmd>NvimTreeToggle<CR>`.
- `lua/plugins/nvimtree.lua:17-19` sets `filters.dotfiles = false`, so dotfiles are not filtered by nvim-tree.
- `lua/plugins/nvimtree.lua:20-22` disables nvim-tree git integration.
- `lua/plugins/nvimtree.lua:23-35` enables filesystem watchers with `debounce_delay = 50` and `ignore_dirs` for `.ccls-cache`, `build`, `node_modules`, `target`, `.git`, `.idea`, and `.gradle`.
- `lua/plugins/nvimtree.lua:36-44` disables nvim-tree diagnostics and defines diagnostic icons that are unused while disabled.

Current integrations tied to nvim-tree:

- `lua/plugins/bufferline.lua:30` has `offsets = { { filetype = "NvimTree" } }`.
- `lua/plugins/claudecode.lua:17-22` maps `<leader>as` to `ClaudeCodeTreeAdd` only for filetypes `{ "NvimTree", "neo-tree", "oil", "minifiles", "netrw" }`.

### Enabling Snacks Explorer

Snacks docs show lazy.nvim setup with `opts.explorer` for general explorer config and `opts.picker.sources.explorer` for explorer picker config:

```lua
-- C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/docs/explorer.md:15-35
{
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    explorer = {
      -- general explorer configuration
    },
    picker = {
      sources = {
        explorer = {
          -- explorer picker configuration
        }
      }
    }
  }
}
```

The installed Snacks version auto-enables configured snacks unless `enabled` is explicitly false:

- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/init.lua:149-154` sets `opts[k].enabled = opts[k].enabled == nil or opts[k].enabled` while merging setup options.
- In this project, `lua/plugins/snacks.lua:57` explicitly sets `explorer = { enabled = false }`, so migration must remove that false value or set `enabled = true`.

Explorer general defaults:

```lua
-- C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/explorer/init.lua:17-20
local defaults = {
  replace_netrw = true, -- Replace netrw with the snacks explorer
  trash = true, -- Use the system trash when deleting files
}
```

The docs repeat those general defaults at `docs/explorer.md:153-158` and state that explorer picker settings belong to `snacks.picker.explorer.Config` at `docs/explorer.md:148-152`.

`replace_netrw` behavior:

- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/docs/explorer.md:8-12` says that with explorer and `replace_netrw` enabled, the explorer opens when starting `nvim` with a directory or opening a directory in Vim.
- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/explorer/init.lua:26-70` implements this by deleting the `FileExplorer` augroup, handling directory buffers on `BufEnter`, opening explorer with `cwd = ev.file`, clearing the original directory buffer name on startup, and deleting directory buffers after Vim has entered.

### Toggle/Open Keymap API

Documented module API:

- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/docs/explorer.md:163-168`: `Snacks.explorer()` is typed as `fun(opts?: snacks.picker.explorer.Config): snacks.Picker`.
- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/docs/explorer.md:176-183`: `Snacks.explorer.open(opts)` is the shortcut to open the explorer picker.
- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/docs/explorer.md:185-192`: `Snacks.explorer.reveal({ file?: string, buf?: number })` reveals a file/buffer or current buffer.

Source behavior:

- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/explorer/init.lua:1-7` makes `Snacks.explorer(...)` call `M.open(...)` through `__call`.
- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/explorer/init.lua:73-77` implements `M.open(opts)` as `return Snacks.picker.explorer(opts)`.
- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/explorer/init.lua:79-108` implements `M.reveal(opts)` by finding or opening an active explorer picker and updating target selection.
- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/picker/init.lua:77-82` closes an active picker when opening another picker with the same `source`; for `source = "explorer"`, this gives `Snacks.explorer()` toggle-like close/open behavior.

Documented keymap example:

- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/README.md:221-228` shows `{ "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" }`.

No `:SnacksExplorer` user command was found in the installed Snacks docs/source during this research; the documented API is Lua function based.

### Explorer Navigation and Internal Keymaps

Docs navigation and quick actions:

- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/docs/explorer.md:90-99` documents `<CR>`/`l` to open/toggle, `h` to close directory, `<BS>` to go up, `.` to focus current directory as cwd, `H` to toggle hidden files, `I` to toggle ignored files, and `Z` to close all directories.
- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/docs/explorer.md:100-105` documents `<leader>/` grep, `<c-t>` terminal, `<c-c>` tab cwd, and `P` preview toggle.

Source keymaps:

- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/picker/config/sources.lua:77-108` defines list-window mappings, including `<BS>`, `l`, `h`, `a`, `d`, `r`, `c`, `m`, `o`, `P`, `y`, `p`, `u`, `<c-c>`, `<leader>/`, `<c-t>`, `.`, `I`, `H`, `Z`, `]g`, `[g`, `]d`, `[d`, `]w`, `[w`, `]e`, `[e`.
- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/explorer/actions.lua:317-328` implements confirm: when searching it updates the explorer target; for directories it toggles the tree node; for files it jumps via picker actions.

### Filetype and Buffer Identity for Integrations

Snacks explorer is a picker in disguise, so it uses picker/layout filetypes rather than a unique explorer filetype:

- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/docs/explorer.md:1-6` states explorer is a picker in disguise.
- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/picker/core/list.lua:71-82` creates the list window buffer with `filetype = "snacks_picker_list"`.
- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/picker/core/input.lua:22-46` creates the input window buffer with `filetype = "snacks_picker_input"` and `buftype = "prompt"`.
- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/layout.lua:85-95` creates layout box buffers with `filetype = "snacks_layout_box"`, `buftype = "nofile"`, and `vim.w[win].snacks_layout = true`.
- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/picker/core/preview.lua:84` uses `scratch_ft = "snacks_picker_preview"` for preview buffers.

No stable explorer-specific buffer name was found. The relevant buffers are scratch/layout buffers with filetypes above. The only explorer-specific buffer-name operation found is for netrw replacement startup: `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/explorer/init.lua:37-38` clears the original directory buffer name so it is not loaded again.

Integration implication from external references:

- Snacks discussion #1147 and issue #2097 both note that `snacks_picker_list` is not unique to explorer because all pickers share picker windows. They describe checking active explorer pickers with `Snacks.picker.get({ source = "explorer" })` and comparing windows such as `picker.layout.wins["list"].win` when a unique explorer identity is required.
- This aligns with source: active picker filtering by source is implemented at `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/picker/core/picker.lua:60-76` and exposed as `Snacks.picker.get(opts)` at `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/picker/init.lua:103-108`.

### Bufferline Offset Findings

Current project:

- `lua/plugins/bufferline.lua:30` uses `offsets = { { filetype = "NvimTree" } }`.

Snacks source/filetypes:

- The visible list buffer is `snacks_picker_list` (`picker/core/list.lua:71-82`).
- The sidebar/layout wrapper buffer is `snacks_layout_box` (`layout.lua:85-95`).

External references on bufferline offsets:

- `akinsho/bufferline.nvim` issue #996 reports that `offsets = { { filetype = "snacks_picker_list" } }` did not work as expected for Snacks explorer, even though the list filetype was reported as `snacks_picker_list`.
- Snacks discussion #1340 reports a working bufferline offset using:

```lua
offsets = {
  {
    filetype = "snacks_layout_box",
    text = "File Explorer",
    separator = true,
  },
}
```

Caveat: `snacks_layout_box` is also not unique to explorer; it is used by layout boxes generally (`layout.lua:85-95`). External discussion #1147 notes that filetype-only matching can also catch other picker layout boxes.

### ClaudeCodeTreeAdd Findings

Current project keymap:

- `lua/plugins/claudecode.lua:17-22` scopes `<leader>as` / `ClaudeCodeTreeAdd` to `{ "NvimTree", "neo-tree", "oil", "minifiles", "netrw" }`.

Installed claudecode integration support:

- `C:/Users/alleg/AppData/Local/nvim-data/lazy/claudecode.nvim/lua/claudecode/integrations.lua:10-25` branches only on `NvimTree`, `neo-tree`, `oil`, `minifiles`, and `netrw`; any other filetype returns `Not in a supported tree buffer (current filetype: ...)`.
- No `snacks_picker_list`, `snacks_layout_box`, or Snacks explorer branch was found in the installed `claudecode.nvim` integration module.

External reference:

- `coder/claudecode.nvim` issue #192, "Support ClaudeCodeTreeAdd in snacks_picker_list", is open. It reports the exact error `Not in a supported tree buffer (current filetype: snacks_picker_list)` when attempting to use `ClaudeCodeTreeAdd` from Snacks pickers.

Implication: adding `snacks_picker_list` to the lazy.nvim keymap `ft` list would make the keymap available in the Snacks list buffer, but the installed `ClaudeCodeTreeAdd` command still lacks Snacks selection logic and will reject the filetype unless claudecode gains support or local integration logic is added elsewhere.

### Dotfile Visibility and Hidden/Ignored Behavior

Current nvim-tree behavior:

- `lua/plugins/nvimtree.lua:17-19` sets `filters.dotfiles = false`, so dotfiles are visible in the current nvim-tree setup.

Snacks defaults and behavior:

- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/picker/config/sources.lua:191-209` defines file picker options with `hidden = false`, `ignored = false`, and `follow = false` by default.
- Explorer extends files config: `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/picker/config/sources.lua:39-50` declares explorer config as `snacks.picker.files.Config` plus explorer fields.
- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/explorer/tree.lua:79-92` marks a node hidden when the basename begins with `.`.
- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/explorer/tree.lua:208-227` filters nodes in this order: `include` override, hidden check, ignored check, exclude check.
- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/picker/source/files.lua:92-102` maps `hidden = true` to `fd`/`rg` `--hidden` and maps `ignored = true` to `--no-ignore`.
- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/picker/config/sources.lua:97-98` maps `I` to `toggle_ignored` and `H` to `toggle_hidden` in the explorer list.

Config implication for current dotfile parity: Snacks default `hidden = false` hides dotfiles, unlike current nvim-tree `filters.dotfiles = false`; dotfile parity requires setting explorer picker `hidden = true` under `opts.picker.sources.explorer` or toggling with `H` at runtime.

Hidden and ignored are separate in Snacks: `H` affects dotfiles/hidden files, while `I` affects gitignored files. External issue #1194 shows confusion around hidden directories and ignored files during reveal/search workflows; one comment notes that "Hidden" is not the same as "Ignored".

### Git Behavior Parity

Current nvim-tree behavior:

- `lua/plugins/nvimtree.lua:20-22` sets `git.enable = false`.

Snacks default behavior:

- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/picker/config/sources.lua:55-60` defaults explorer to `watch = true`, `diagnostics = true`, `git_status = true`, `git_status_open = false`, and `git_untracked = true`.
- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/docs/explorer.md:107-113` documents that `git_status = true` shows git status indicators and `]g` / `[g` jump to next/previous git change.
- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/picker/source/explorer.lua:207-218` updates git status when `opts.git_status` is true.
- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/explorer/git.lua:32-70` runs `git status --porcelain=v1 --ignored=matching -z` and uses `-unormal` when untracked status is enabled, otherwise `-uno`.
- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/explorer/git.lua:118-160` updates tree node `status`, `ignored`, and directory aggregate status.
- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/explorer/actions.lua:170-198` implements `]g` / `[g` navigation.

Config implication for current nvim-tree git parity: Snacks default `git_status = true` differs from current nvim-tree `git.enable = false`; git parity requires setting explorer picker `git_status = false`. If git status is enabled, `git_untracked = true` means untracked files participate in status indicators by default.

### Diagnostic Behavior Parity

Current nvim-tree behavior:

- `lua/plugins/nvimtree.lua:36-44` sets `diagnostics.enable = false`; the icon table is unused while disabled.

Snacks default behavior:

- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/picker/config/sources.lua:55-57` defaults `diagnostics = true` and `diagnostics_open = false`.
- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/docs/explorer.md:114-120` documents diagnostic indicators and `]d` / `[d`, `]e` / `[e`, `]w` / `[w` navigation.
- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/picker/source/explorer.lua:92-110` debounces diagnostic updates on `InsertLeave` and `DiagnosticChanged` when diagnostics are enabled.
- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/picker/source/explorer.lua:220-222` updates diagnostics during explorer find when enabled.
- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/explorer/diagnostics.lua:5-37` reads all diagnostics with `vim.diagnostic.get()`, normalizes diagnostic buffer paths, and propagates severity to cwd and parent directories.
- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/explorer/actions.lua:330-348` implements diagnostic/warn/error next/previous actions.

Config implication for current nvim-tree diagnostic parity: Snacks default `diagnostics = true` differs from current nvim-tree `diagnostics.enable = false`; diagnostic parity requires setting explorer picker `diagnostics = false`.

### Watch Behavior Parity

Current nvim-tree behavior:

- `lua/plugins/nvimtree.lua:23-35` enables filesystem watchers with `debounce_delay = 50` and explicit `ignore_dirs` list.

Snacks default behavior:

- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/picker/config/sources.lua:55` defaults `watch = true`.
- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/picker/source/explorer.lua:50-60` installs watch cleanup/update behavior when `opts.watch` is true.
- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/picker/source/explorer.lua:145-152` calls `require("snacks.explorer.watch").watch()` during explorer setup when watch is enabled.
- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/explorer/watch.lua:78-116` watches the git root `.git` directory for `index` changes and watches open tree directories; it stops unused watches.
- `C:/Users/alleg/AppData/Local/nvim-data/lazy/snacks.nvim/lua/snacks/explorer/watch.lua:57-75` batches refreshes with a fixed `timer:start(100, 0, ...)` delay.

No direct Snacks explorer options named `ignore_dirs` or `debounce_delay` were found. Snacks explorer does support `exclude`/`include` filtering (`sources.lua:48-49`, `tree.lua:208-227`, `files.lua:62-73`), but the watcher implementation itself does not expose the same nvim-tree watcher ignore list shape.

Config implication for current nvim-tree watch parity: Snacks default `watch = true` matches the high-level current watcher enabled state, but its implementation differs: fixed 100 ms refresh batching, watches only open directories plus `.git` index, and has no direct `filesystem_watchers.ignore_dirs` equivalent.

External watch caveat:

- Snacks issue #1308 discusses flickering/continuous refresh. Maintainer comments point to constantly changing files or LSP diagnostic updates; a suggested diagnostic step is setting `opts.picker.sources.explorer.watch = false`.

### Migration Pitfalls from nvim-tree

1. **API and command shape changes**
   - Current keymap uses `:NvimTreeToggle` (`lua/plugins/nvimtree.lua:5`). Snacks docs/source expose Lua APIs `Snacks.explorer()`, `Snacks.explorer.open(opts)`, and `Snacks.explorer.reveal(opts)`; no `:SnacksExplorer` command was found.

2. **Explorer is a picker, not a dedicated tree buffer**
   - Snacks docs call explorer a picker in disguise (`docs/explorer.md:1-6`). Filetypes are picker/layout filetypes, not `NvimTree`. Filetype-only integrations can match other Snacks pickers.

3. **Bufferline offset filetype is not the visible list filetype in reported working configs**
   - Source shows `snacks_picker_list` for the list and `snacks_layout_box` for the wrapper. External bufferline issue #996 reports `snacks_picker_list` offset did not work; Snacks discussion #1340 reports `snacks_layout_box` as working.

4. **ClaudeCodeTreeAdd is not supported by installed claudecode.nvim for Snacks**
   - Current keymap excludes Snacks filetypes (`lua/plugins/claudecode.lua:21`). Installed `claudecode.integrations` rejects unsupported filetypes at lines 10-25. External issue #192 requests Snacks support and is open.

5. **Defaults differ from current nvim-tree config**
   - Current nvim-tree shows dotfiles, disables git, disables diagnostics, and enables watchers. Snacks defaults hide dotfiles (`hidden = false`), show git status (`git_status = true`), show diagnostics (`diagnostics = true`), and enable watch (`watch = true`).

6. **Hidden and ignored are separate controls**
   - Snacks uses `H` for hidden and `I` for gitignored. Setting/toggling one does not set/toggle the other.

7. **Watcher configuration is not a one-to-one migration**
   - nvim-tree has `filesystem_watchers.ignore_dirs` and `debounce_delay`; Snacks explorer watch source has no direct equivalents and uses fixed 100 ms refresh batching.

8. **Delete behavior uses Snacks explorer trash default**
   - Snacks explorer general config defaults `trash = true` (`explorer/init.lua:17-20`), and delete uses system trash when available (`explorer/actions.lua:37-61`, `actions.lua:295-315`).

### Config Shape Needed for Parity

This is the option shape implicated by the research, using current project parity values:

```lua
opts = {
  explorer = {
    enabled = true,
    replace_netrw = true,
    -- trash = true, -- Snacks default
  },
  picker = {
    enabled = true,
    sources = {
      explorer = {
        hidden = true,        -- parity with nvim-tree filters.dotfiles = false
        git_status = false,   -- parity with nvim-tree git.enable = false
        diagnostics = false,  -- parity with nvim-tree diagnostics.enable = false
        watch = true,         -- parity with nvim-tree filesystem_watchers.enable = true at high level
        -- exclude = { ... }, -- available for filtering, but not the same as nvim-tree watcher ignore_dirs
      },
    },
  },
}
```

The documented keymap API shape is:

```lua
{ "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" }
```

The researched integration filetypes are:

```lua
-- Snacks picker/explorer buffers
"snacks_layout_box"      -- layout wrapper; reported working for bufferline offset
"snacks_picker_list"     -- visible picker/explorer list
"snacks_picker_input"    -- picker input prompt
"snacks_picker_preview"  -- preview scratch buffer
```

## External References

- [Snacks explorer docs](https://github.com/folke/snacks.nvim/blob/main/docs/explorer.md) — Documents explorer as a picker, setup, `replace_netrw`, navigation, git/diagnostics, config, `Snacks.explorer()`, `open()`, and `reveal()`.
- [Snacks picker source defaults](https://raw.githubusercontent.com/folke/snacks.nvim/main/lua/snacks/picker/config/sources.lua) — Defines default explorer picker settings: `watch = true`, `diagnostics = true`, `git_status = true`, `git_untracked = true`, `hidden = false`/`ignored = false` inherited from files config, and explorer keymaps.
- [bufferline.nvim issue #996](https://github.com/akinsho/bufferline.nvim/issues/996) — Reports `snacks_picker_list` offset not working and points to `snacks_layout_box` as the working offset filetype.
- [Snacks discussion #1340](https://github.com/folke/snacks.nvim/discussions/1340) — Shows bufferline offset config using `filetype = "snacks_layout_box"`.
- [Snacks discussion #1147](https://github.com/folke/snacks.nvim/discussions/1147) — Discusses explorer filetypes not being unique and using `Snacks.picker.get({ source = "explorer" })` plus window IDs for precise integration.
- [Snacks issue #2097](https://github.com/folke/snacks.nvim/issues/2097) — Asks for a unique explorer filetype; comments describe `snacks_picker_list` not being unique and using active explorer picker windows.
- [claudecode.nvim issue #192](https://github.com/coder/claudecode.nvim/issues/192) — Open request to support `ClaudeCodeTreeAdd` in `snacks_picker_list`; includes the current unsupported-filetype error.
- [Snacks issue #1308](https://github.com/folke/snacks.nvim/issues/1308) — Watch/diagnostic refresh flicker discussion; mentions setting `opts.picker.sources.explorer.watch = false` as a diagnostic workaround.
- [Snacks issue #1194](https://github.com/folke/snacks.nvim/issues/1194) — Hidden directory/reveal discussion; highlights the distinction between hidden and ignored files.

## Related Specs

- `.trellis/spec/frontend/quality-guidelines.md` — Keymap guidance: avoid duplicate keymaps, keep plugin-owned keymaps with plugin specs, and group leader mappings before child mappings.
- `.trellis/spec/frontend/hook-guidelines.md` — Plugin-specific autocommands can live inside plugin specs when they depend on the plugin.
- `.trellis/spec/frontend/type-safety.md` — Optional plugin APIs should be guarded with availability checks; relevant for any local integration logic around plugin APIs.
- `.trellis/spec/backend/database-guidelines.md` — Lockfile entries are generated by lazy.nvim and should not be hand-edited except intentional repair.

## Caveats / Not Found

- No `:SnacksExplorer` command was found in the installed Snacks source/docs; documented usage is through Lua functions.
- No unique Snacks explorer filetype was found; `snacks_picker_list`, `snacks_picker_input`, and `snacks_layout_box` are picker/layout filetypes and may also appear for non-explorer pickers.
- No stable explorer-specific buffer name was found; the integration identity available in source is the picker source (`source = "explorer"`) and active picker/window metadata.
- No direct Snacks explorer equivalents were found for nvim-tree `filesystem_watchers.ignore_dirs` or `debounce_delay`.
- Installed `claudecode.nvim` does not support Snacks explorer/list selection in `ClaudeCodeTreeAdd`; external support request #192 is open.
