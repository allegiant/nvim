# Quality Guidelines

> Code quality standards for editor-facing UI, keymaps, and plugin configuration.

---

## Overview

Frontend quality in this repository means keeping the editor interaction surface consistent, discoverable, and safe across normal Neovim, VS Code Neovim, Neovide, Windows, and WSL.

There is no browser accessibility suite, frontend linter, or TypeScript check. Review UI changes by checking keymap consistency, lazy.nvim spec shape, startup behavior, and environment guards.

---

## Forbidden Patterns

- Do not define the same keymap in multiple normal-Neovim plugin/core files without a deliberate reason. Check `lua/core/mappings.lua`, `lua/plugins/lspconfig.lua`, `lua/plugins/snacks.lua`, and the relevant plugin file first.
- Do not put VS Code-only mappings or `VSCodeNotify` calls outside `lua/config/vscode.lua`.
- Do not add plugin keymaps without descriptions in lazy.nvim `keys` arrays when the surrounding file uses `desc`.
- Do not introduce web frontend tooling or directories (`src/components`, `hooks`, CSS frameworks) for this Neovim config.
- Do not make UI plugins eager (`lazy = false`) unless there is an existing startup need like `lua/plugins/snacks.lua`.

---

## Required Patterns

- Group leader mappings before child mappings, following examples such as `{ "<leader>f", group = "File" }` in `lua/plugins/snacks.lua` and `{ "<leader>b", group = "Buffer" }` in `lua/plugins/bufferline.lua`.
- Keep plugin-owned keymaps with the plugin spec. For example, Snacks owns `<leader>e` in `lua/plugins/snacks.lua` via `lua/plugins/snacks/explorer.lua`, ToggleTerm owns `<leader>t...` in `lua/plugins/toggleterm.lua`, and Conform owns `<leader>fm` in `lua/plugins/conform.lua`.
- Keep related UI option tables local to the plugin file and pass them through `opts` or `setup(...)` consistently.
- Preserve mode-specific keymaps. Terminal-mode mappings use `vim.keymap.set('t', ...)` in `lua/plugins/toggleterm.lua`; visual clipboard mappings use `map("v", ...)` in `lua/core/mappings.lua` and `vim.keymap.set({ "v" }, ...)` in `lua/config/vscode.lua`.
- Keep plugin-owned terminal keymaps scoped to the owning plugin's buffers. ToggleTerm-only mappings belong on `TermOpen term://*toggleterm#*`; avoid `term://*` unless the intent is to affect every Neovim terminal, including Claude Code terminals.

---

## Scenario: Snacks Explorer Integration

### 1. Scope / Trigger

- Trigger: Any change to Snacks explorer, file explorer keymaps, tabbar explorer offsets, or tree-buffer integrations such as ClaudeCode tree-add behavior.
- Applies when `folke/snacks.nvim` provides the file explorer through `lua/plugins/snacks.lua` and helper modules under `lua/plugins/snacks/`.

### 2. Signatures

- Explorer entry keymap:

```lua
{ "<leader>e", explorer.open, desc = "File Explorer" }
```

- Helper module shape:

```lua
local explorer = require("plugins.snacks.explorer")
explorer.open()
explorer.options(opts?)
```

- Tabbar explorer offset uses the Snacks layout wrapper filetype and must not render `File Explorer` text above the sidebar:

```lua
local explorer_filetype = "snacks_layout_box"
```

### 3. Contracts

- `lua/plugins/snacks.lua` owns the normal-Neovim `<leader>e` explorer entry.
- `lua/plugins/snacks/explorer.lua` owns Snacks explorer helper/config code and must not add an `init.lua` under `lua/plugins/snacks/`.
- Snacks explorer internal picker/list keymaps should stay at upstream defaults unless a task explicitly asks to override them.
- Explorer-only picker key overrides belong under `picker.sources.explorer.win.<window>.keys`; do not change `picker.win.*.keys` unless the task intentionally changes every Snacks picker.
- Disable an inherited Snacks picker key for explorer by setting the source-scoped key entry to `false`, for example `picker.sources.explorer.win.list.keys.q = false`.
- If disabling an inherited picker key that exists in multiple picker windows, cover each inherited window used by the explorer (`input`, `list`, and `preview` for the default `q = "cancel"`).
- Snacks explorer is picker-backed, so filetypes such as `snacks_picker_list` and `snacks_layout_box` are not unique explorer-only identities.
- Do not expose `ClaudeCodeTreeAdd` for Snacks picker filetypes unless claudecode upstream or local integration code actually supports resolving the selected Snacks explorer item.

### 4. Validation & Error Matrix

- Duplicate `<leader>e` in normal-Neovim plugin/core files -> remove or consolidate the duplicate before shipping.
- `NvimTree`, `NvimTreeToggle`, or `nvim-tree/nvim-tree.lua` remains in `lua/**/*.lua` -> stale explorer migration; remove or replace it.
- `ClaudeCodeTreeAdd` is bound to `snacks_picker_list` without supported integration -> visible keymap fails at runtime with unsupported filetype; do not bind it.
- `lua/plugins/snacks/` contains helper-only modules with `init.lua` -> lazy.nvim may treat the directory as an importable plugin spec; avoid helper-directory `init.lua`.

### 5. Good/Base/Bad Cases

- Good: `<leader>e` calls `explorer.open`, `explorer.options()` enables Snacks explorer, tabbar offset detects `snacks_layout_box`, and ClaudeCode tree-add remains scoped only to supported tree filetypes.
- Good: Explorer-specific picker key changes use `picker.sources.explorer.win.list.keys`, such as mapping `o` to `confirm`, and disable inherited picker keys source-locally with `false`.
- Base: A task changes only `<leader>e`; it still checks normal-Neovim duplicate keymaps and leaves VS Code-only `<leader>e` isolated in `lua/config/vscode.lua`.
- Bad: Adding `snacks_picker_list` to `ClaudeCodeTreeAdd` filetypes just because Snacks explorer uses picker buffers.
- Bad: Disabling `q` through global `picker.win.*.keys` when only the explorer should stop responding to `q`.

### 6. Tests Required

- Run headless startup:

```powershell
nvim --headless "+luafile init.lua" "+qa"
```

- Validate helper module shape when it changes:

```powershell
nvim --headless "+lua local explorer = require('plugins.snacks.explorer'); assert(type(explorer.open) == 'function'); assert(explorer.options().enabled == true)" "+qa"
```

- Validate plugin graph excludes old nvim-tree when replacing the explorer:

```powershell
nvim --headless "+lua local plugins=require('lazy.core.config').plugins; assert(plugins['nvim-tree.lua'] == nil); assert(plugins['snacks.nvim'] ~= nil)" "+qa"
```

- Search runtime Lua for stale explorer references:

```powershell
rg "NvimTree|nvim-tree/nvim-tree.lua|NvimTreeToggle|nvimtree" lua
```

### 7. Wrong vs Correct

#### Wrong

```lua
{
  "<leader>as",
  "<cmd>ClaudeCodeTreeAdd<cr>",
  ft = { "snacks_picker_list" },
}
```

#### Correct

```lua
{
  "<leader>as",
  "<cmd>ClaudeCodeTreeAdd<cr>",
  ft = { "neo-tree", "oil", "minifiles", "netrw" },
}
```

---

## Scenario: Tabby Buffer Tabbar

### 1. Scope / Trigger

- Trigger: Any change to `lua/plugins/bufferline.lua`, buffer tabbar rendering, buffer tabbar keymaps, or file-explorer offset behavior.
- Applies when `nanozuki/tabby.nvim` renders the file buffer tabbar for this Neovim config.

### 2. Signatures

- Plugin spec:

```lua
{
  "nanozuki/tabby.nvim",
  event = "VimEnter",
  keys = {
    { "<Tab>", jump_next_buffer, desc = "Buffer next" },
    { "<S-Tab>", jump_prev_buffer, desc = "Buffer prev" },
    { "<leader>b1", function() jump_to_buffer(1) end, desc = "Buffer 1" },
  },
  config = function()
    require("tabby").setup({ line = render_tabline })
  end,
}
```

- Displayed-buffer contract:

```lua
local function displayed_buffers()
  return { bufnr1, bufnr2, ... }
end
```

### 3. Contracts

- `tabby.nvim` owns the top file-buffer tabbar; do not reintroduce `akinsho/bufferline.nvim` or `BufferLine*` commands.
- The tabbar renders normal file buffers only. Filter unnamed buffers, unlisted buffers, non-empty `buftype`, Snacks explorer/picker/dashboard buffers, and terminals.
- Buffer display order and `<leader>bN` jump order must use the same `displayed_buffers()` helper.
- The visual format is a head segment plus closed slant buffer segments, for example `   1 lazy.lua    2 lspconfig.lua `.
- When Snacks explorer is open on the left, hide the head segment and render only an offset followed by the first buffer segment, for example `[offset]  1 lazy.lua `.
- Lowercase `<leader>t...` is not a tab-page workflow in this config. Terminal mappings use uppercase `<leader>T...`.

### 4. Validation & Error Matrix

- `BufferLine` command remains in runtime Lua -> stale migration; remove it.
- `akinsho/bufferline.nvim` remains in the lazy spec -> duplicate tabbar plugin; replace it with `nanozuki/tabby.nvim`.
- A buffer appears in the tabbar but `<leader>bN` jumps elsewhere -> display/jump helper mismatch; use one helper for both.
- `snacks_layout_box`, picker, dashboard, or terminal buffers appear in the tabbar -> filter bug; update the displayed-buffer predicate.
- Explorer open and `` overlaps the sidebar -> offset bug; hide the head segment while left explorer offset is active.

### 5. Good/Base/Bad Cases

- Good: `TabbyRenderTabline()` returns a string containing numbered normal file buffers and closed ``/`` segments.
- Good: `<Tab>`, `<S-Tab>`, and `<leader>b1..b9` all navigate within `displayed_buffers()`.
- Base: With only one normal file buffer, the tabbar still renders the head plus one numbered segment.
- Bad: `line.bufs().filter(...)` receives a table instead of a function; tabby raises `fn: expected callable, got table`.
- Bad: Current-buffer highlight leaks into the right-side fill because the segment does not close back to `TabLineFill`.

### 6. Tests Required

- Run headless startup:

```powershell
nvim --headless "+qa"
```

- Render multiple file buffers:

```powershell
nvim --headless "lua/plugins/bufferline.lua" "lua/plugins/lspconfig.lua" "+lua local ok, out = pcall(vim.fn.TabbyRenderTabline); assert(ok, out); assert(out:find('1 ')); assert(out:find('2 '))" "+qa"
```

- Verify `tabby.nvim` replaced old BufferLine:

```powershell
nvim --headless "+lua local plugins=require('lazy.core.config').plugins; assert(plugins['tabby.nvim']); assert(not plugins['bufferline.nvim'])" "+qa"
```

- Check stale command references:

```powershell
rg "BufferLine|akinsho/bufferline.nvim" lua
```

### 7. Wrong vs Correct

#### Wrong

```lua
line.bufs().filter({ function(buf)
  return vim.bo[buf.id].buflisted
end })
```

#### Correct

```lua
line.bufs()
  .filter(function(buf)
    return vim.tbl_contains(displayed_buffers(), buf.id)
  end)
  .foreach(function(buf, index)
    return buffer_segment(buf, index)
  end)
```

---

## Testing Requirements

No automated UI tests exist. For UI/config changes:

1. Run a headless startup check when Neovim is available:

   ```powershell
   nvim --headless "+luafile init.lua" "+qa"
   ```

2. Manually inspect keymap conflicts in changed files.
3. For VS Code mapping changes, ensure the code remains isolated to `lua/config/vscode.lua`.
4. For terminal/shell changes, review Windows guards in `lua/plugins/toggleterm.lua`.

---

## Code Review Checklist

- Keymaps are discoverable through `desc` and existing leader groups.
- Plugin specs still return valid lazy.nvim tables.
- UI settings stay with the responsible plugin or environment config.
- Normal Neovim, VS Code Neovim, Neovide, Windows, and WSL paths remain guarded.
- New notifications are concise and do not spam high-frequency events.
- No generated plugin/runtime state or local machine paths are committed.
