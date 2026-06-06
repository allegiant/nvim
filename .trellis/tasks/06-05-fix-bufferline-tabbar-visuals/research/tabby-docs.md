# Research: tabby.nvim docs and local source

- **Query**: Research nanozuki/tabby.nvim documentation and local installed source for reducing custom code while achieving a tabline close to README/default style; answer preset/customization/high-level API questions for `.trellis/tasks/06-05-fix-bufferline-tabbar-visuals`.
- **Scope**: mixed — local installed docs/source under `C:\Users\alleg\AppData\Local\nvim-data\lazy\tabby.nvim`, current repo config under `C:\Users\alleg\AppData\Local\nvim`, and GitHub README search confirmation.
- **Date**: 2026-06-06

## Findings

### Direct Answers

#### 1. Recommended/default configuration in current README/API

Current README and help describe two supported setup paths:

1. **Preset quick-start** with `require('tabby').setup({ preset = ..., option = ... })`.
   - README shows the preset form at `C:\Users\alleg\AppData\Local\nvim-data\lazy\tabby.nvim\README.md:773-799`.
   - Help shows the same at `C:\Users\alleg\AppData\Local\nvim-data\lazy\tabby.nvim\doc\tabby.txt:819-845`.
   - Preset options include `theme`, `nerdfont`, `lualine_theme`, `tab_name`, and `buf_name` (`README.md:779-797`, `doc\tabby.txt:824-843`).

2. **Custom line renderer** with `require('tabby').setup({ line = function(line) ... end, option = ... })`.
   - README example uses `line.tabs().foreach`, `line.spacer()`, and `line.wins_in_tab(line.api.get_current_tab()).foreach` at `README.md:180-219`.
   - README notes that recent versions also support `require('tabby.tabline').set(fn, opt?)` at `README.md:222-223`.

Local source shows the default behavior when no `line` is provided:

```lua
if cfg == nil or cfg.line == nil then
  cfg = vim.tbl_extend('force', { preset = 'active_wins_at_tail' }, cfg or {})
  tbl.use_preset(cfg.preset, cfg.option)
else
  tbl.set(cfg.line, cfg.option)
end
```

Source: `C:\Users\alleg\AppData\Local\nvim-data\lazy\tabby.nvim\lua\tabby\init.lua:39-46`.

Other README setup notes:

- Always show the tabline with `vim.o.showtabline = 2` (`README.md:146-153`, `doc\tabby.txt:186-193`).
- Lazy loading is not required because tabby is not slow; if lazy-loaded, `VimEnter` or `VeryLazy` are acceptable but may briefly show the raw tabline first (`README.md:137-142`, `doc\tabby.txt:174-179`).
- Optional icon dependency is needed only when using `file_icon()` (`README.md:128-135`, `doc\tabby.txt:164-171`).

#### 2. Built-in presets and closest README/default style match

Current built-in presets are five names documented in README/help and implemented in `lua\tabby\tabline.lua`:

| Preset | README/help description | Implementation |
|---|---|---|
| `active_wins_at_tail` | Put all windows' labels in active tabpage at end of whole tabline | `tabline.lua:176-192` |
| `active_wins_at_end` | Put active tabpage windows after all tab labels; inactive tab windows are not displayed | `tabline.lua:194-208` |
| `tab_with_top_win` | Each tab label is followed by that tab's top/current window label | `tabline.lua:230-253` |
| `active_tab_with_wins` | Active tabpage's windows displayed after the active tabpage label | `tabline.lua:210-228` |
| `tab_only` | Only tabs, no window labels | `tabline.lua:255-266` |

README list: `C:\Users\alleg\AppData\Local\nvim-data\lazy\tabby.nvim\README.md:808-854`.
Help list: `C:\Users\alleg\AppData\Local\nvim-data\lazy\tabby.nvim\doc\tabby.txt:854-868`.

Closest match to **README/default style** is **`active_wins_at_tail`** because:

- Local `require('tabby').setup()` default is `preset = 'active_wins_at_tail'` when no custom `line` is provided (`init.lua:39-43`).
- README's preset example uses `preset = 'active_wins_at_tail'` (`README.md:775-778`).
- Its layout is head + tabs + spacer + current-tab windows + tail, matching the main README/default visual structure (`tabline.lua:176-192`).

Caveat: README image asset names include `tabby-default-1.png` under `active_wins_at_end` (`README.md:820-829`). If a specific screenshot is the one where active-tab window labels appear immediately after all tabs with no right-side spacer/tail, then `active_wins_at_end` is the closer visual match. For the local installed API's actual default, `active_wins_at_tail` is the default.

#### 3. Whether presets can show tab pages + current windows/buffers without custom low-level line code

Presets can show **tab pages + current windows** without custom low-level line code:

- `active_wins_at_tail` uses `line.tabs()` and `line.wins_in_tab(line.api.get_current_tab())` (`tabline.lua:181-187`).
- `active_wins_at_end` uses `line.tabs()` and `line.wins_in_tab(line.api.get_current_tab())` (`tabline.lua:199-203`).
- `active_tab_with_wins` uses `line.tabs()` and `tab.wins()` for the active tab only (`tabline.lua:215-223`).
- `tab_with_top_win` uses `line.tabs()` and `tab.current_win()` (`tabline.lua:244-248`).

The window label itself uses `win.buf_name()` (`tabline.lua:148-157`), so the visible text is the window's buffer name and can be shaped with `option.buf_name.mode` (`unique`, `relative`, `tail`, `shorten`) documented at `README.md:418-443` and implemented via `buf_name.get_by_bufid()` at `lua\tabby\feature\buf_name.lua:52-60`.

Presets cannot show **all listed buffers** as a bufferline-style section. Current preset implementations at `tabline.lua:176-266` do not call `line.bufs()`. `line.bufs()` exists as a custom-line helper (`README.md:338-342`; `doc\tabby.txt:386-390`; implementation `lua\tabby\feature\lines.lua:58-63`), but no built-in preset exposes a `show_buffers`/`buffers` option.

#### 4. High-level API/layout options that can reduce current custom code

High-level reduction options that exist:

- `require('tabby').setup({ preset = 'active_wins_at_tail', option = { ... } })` selects a complete built-in tabline (`README.md:773-799`; `init.lua:39-44`; `tabline.lua:271-286`).
- `option.theme` controls `fill`, `head`, `current_tab`, `tab`, `win`, and `tail` highlights (`README.md:779-786`; `tabline.lua:70-87`). Highlight values can be group names or `{ fg, bg, style }` tables (`README.md:717-733`).
- `option.nerdfont` toggles Nerd Font icons/separators (`README.md:787`; `tabline.lua:92-119`, `tabline.lua:126-157`).
- `option.lualine_theme` can derive a preset theme from lualine if `theme` is not set (`README.md:804-806`; `tabline.lua:160-173`).
- `option.buf_name` controls names used by `win.buf_name()` and `buf.name()` (`README.md:418-443`; `buf_name.lua:52-60`).

High-level helpers for a custom line also exist and reduce low-level rendering:

- `line.tabs()`, `line.wins()`, `line.wins_in_tab(tabid)`, `line.bufs()` are provided by `lines.get_line()` (`lua\tabby\feature\lines.lua:40-63`).
- `line.sep`, `line.spacer`, and `line.truncate_point` are provided by `lines.get_line()` (`lines.lua:64-82`).
- `Tabs`, `Wins`, and `Bufs` objects support `.filter()` and `.foreach()` (`tabs.lua:93-112`, `wins.lua:48-67`, `bufs.lua:100-119`).

A current README/API **layout option** such as `layout = 'tabs | buffers'` was not found. The only current high-level layout selector is the preset name. The `layout = ...` fields in `C:\Users\alleg\AppData\Local\nvim-data\lazy\tabby.nvim\lua\tabby\presets.lua:40-91` belong to the legacy config path: `legacy\config.lua` imports `tabby.presets` (`legacy\config.lua:1`) and uses it as a legacy default (`legacy\config.lua:14-17`). Current `tabby.setup()` routes non-legacy config through `tabby.tabline.use_preset()` (`init.lua:37-46`).

No documented or sourced sidebar/offset option was found in tabby. Searching local docs/source for `offset`/`sidebar` only found the README example for filtering NvimTree windows (`README.md:565-573`; `doc\tabby.txt:613-621`), not a bufferline-style offset API.

#### 5. If user wants `tabs | buffers`, whether custom `line.bufs()` is unavoidable

For **actual listed buffers** (`tabs | buffers`), custom `line.bufs()` is unavoidable with current tabby presets:

- Listed buffers come from `api.get_bufs()`, which filters `vim.fn.getbufinfo()` to valid listed buffers (`lua\tabby\module\api.lua:59-67`).
- `line.bufs()` wraps those ids into `TabbyBufs` (`lua\tabby\feature\lines.lua:58-63`).
- `TabbyBufs.filter()` and `TabbyBufs.foreach()` provide the high-level custom-line API (`lua\tabby\feature\bufs.lua:100-119`).
- Preset code uses tabs and windows only (`tabline.lua:176-266`); it does not call `line.bufs()`.

If the user accepts **tabs + current tab windows** instead of **tabs + all listed buffers**, then `active_wins_at_tail` or `active_wins_at_end` can handle it without a custom line. The window labels are buffer names through `win.buf_name()` (`tabline.lua:148-157`), so they can look buffer-like, but they represent windows in the current tabpage, not all listed buffers.

#### 6. Minimal maintainable config recommendation for this repo

For a README/default-style tabline with minimal custom code, the smallest maintainable shape is the preset path:

```lua
opts = {
  preset = "active_wins_at_tail",
  option = {
    theme = {
      fill = theme.fill,
      head = theme.head,
      current_tab = theme.current_tab,
      tab = theme.tab,
      win = theme.buf,
      tail = theme.buf,
    },
    nerdfont = true,
    buf_name = { mode = "tail" },
  },
}
```

This matches current tabby's default/preset API and avoids maintaining custom tab/tab-window rendering code. It is enough when the acceptable display is **tabs + current tab windows**.

For this repo's current task constraints, there are two important caveats:

1. The active task requires preserving a Snacks explorer offset / non-overlap behavior. The current local config implements that manually with `snacks_sidebar_width()` and `sidebar_offset()` (`C:\Users\alleg\AppData\Local\nvim\lua\plugins\bufferline.lua:132-176`) and injects it before the tab/head segments (`bufferline.lua:209-218`). Tabby docs/source did not reveal a built-in offset/sidebar option.
2. The current local config shows **tabs + listed buffers** by using `line.bufs().filter(...).foreach(...)` (`bufferline.lua:209-230`). Built-in presets show **tabs + windows**, not listed buffers.

Therefore:

- If preserving **README/default style** and reducing custom rendering is higher priority than showing all listed buffers, use `preset = 'active_wins_at_tail'` with `option.theme` and `buf_name.mode = 'tail'`.
- If preserving **`tabs | buffers`** and **Snacks explorer offset** is required, keep a custom `line` function, but it can stay on tabby's high-level helpers (`line.tabs()`, `line.bufs()`, `line.spacer()`, `line.sep()`) rather than legacy `components` or manual string tabline code.

### Files Found

| File Path | Description |
|---|---|
| `C:\Users\alleg\AppData\Local\nvim-data\lazy\tabby.nvim\README.md` | Current local README; documents setup, presets, line helpers, options, commands, and preset screenshots. |
| `C:\Users\alleg\AppData\Local\nvim-data\lazy\tabby.nvim\doc\tabby.txt` | Generated Vim help; mirrors README with help tags and preset/API details. |
| `C:\Users\alleg\AppData\Local\nvim-data\lazy\tabby.nvim\lua\tabby\init.lua` | Main setup entry; detects legacy config and defaults modern config to `active_wins_at_tail` when no custom line is supplied. |
| `C:\Users\alleg\AppData\Local\nvim-data\lazy\tabby.nvim\lua\tabby\tabline.lua` | Current preset implementations and `tabline.use_preset()` dispatch; source of supported preset behavior. |
| `C:\Users\alleg\AppData\Local\nvim-data\lazy\tabby.nvim\lua\tabby\feature\lines.lua` | Defines high-level `line` helper object: tabs, wins, wins_in_tab, bufs, sep, spacer, truncate_point, api. |
| `C:\Users\alleg\AppData\Local\nvim-data\lazy\tabby.nvim\lua\tabby\feature\tabs.lua` | `TabbyTab` and `TabbyTabs`; tab label data, close button, jump mode, foreach/filter. |
| `C:\Users\alleg\AppData\Local\nvim-data\lazy\tabby.nvim\lua\tabby\feature\wins.lua` | `TabbyWin` and `TabbyWins`; current-window detection, window buffer-name labels, foreach/filter. |
| `C:\Users\alleg\AppData\Local\nvim-data\lazy\tabby.nvim\lua\tabby\feature\bufs.lua` | `TabbyBuf` and `TabbyBufs`; listed-buffer labels, changed state, foreach/filter, click wrapping. |
| `C:\Users\alleg\AppData\Local\nvim-data\lazy\tabby.nvim\lua\tabby\feature\buf_name.lua` | Buffer-name resolver and `buf_name` option application for windows and buffers. |
| `C:\Users\alleg\AppData\Local\nvim-data\lazy\tabby.nvim\lua\tabby\module\api.lua` | Neovim API wrapper; includes `get_tabs`, `get_tab_wins`, `get_wins`, and `get_bufs`. |
| `C:\Users\alleg\AppData\Local\nvim-data\lazy\tabby.nvim\lua\tabby\presets.lua` | Legacy preset table with `layout` fields; used by `legacy\config.lua`, not the current README setup path. |
| `C:\Users\alleg\AppData\Local\nvim-data\lazy\tabby.nvim\lua\tabby\legacy\config.lua` | Legacy config default imports `tabby.presets`; helps distinguish legacy `layout` fields from current API. |
| `C:\Users\alleg\AppData\Local\nvim\lua\plugins\bufferline.lua` | Current repo tabby plugin config; contains custom sidebar offset, custom tab labels, custom buffer labels, buffer/tab keymaps. |
| `C:\Users\alleg\AppData\Local\nvim\lazy-lock.json` | Pins local `tabby.nvim` to branch `main`, commit `3c130e1fcb598ce39a9c292847e32d7c3987cf11`. |
| `C:\Users\alleg\AppData\Local\nvim\.trellis\tasks\06-05-fix-bufferline-tabbar-visuals\prd.md` | Active task PRD; requires explorer offset and visual separation for the top tabline. |

### Code Patterns

#### Modern setup path vs legacy config

- Modern non-legacy config is detected when `cfg` does not contain `tabline`, `components`, or `opt` (`init.lua:16-19`).
- In modern config, `tabby.setup(cfg)` uses presets if `cfg.line` is absent and custom renderer if `cfg.line` exists (`init.lua:37-46`).
- Legacy defaults still exist (`legacy\config.lua:14-17`) and use `lua\tabby\presets.lua`, but this is separate from the current README preset implementation in `lua\tabby\tabline.lua`.

#### Preset rendering shape

`active_wins_at_tail` current source:

```lua
return {
  preset_head(line, o),
  line.tabs().foreach(function(tab)
    return preset_tab(line, tab, o)
  end),
  line.spacer(),
  line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
    return preset_win(line, win, o)
  end),
  preset_tail(line, o),
  hl = o.theme.fill,
}
```

Source: `C:\Users\alleg\AppData\Local\nvim-data\lazy\tabby.nvim\lua\tabby\tabline.lua:178-190`.

This is the most relevant built-in pattern for a default/README-style line with tabs on the left and current-tab window labels toward the tail.

#### Preset customization boundary

Preset options merge with defaults at each preset (`tabline.lua:176-177`, `tabline.lua:194-195`, `tabline.lua:210-211`, `tabline.lua:240-241`, `tabline.lua:255-256`). Defaults are:

- `theme.fill`, `theme.head`, `theme.current_tab`, `theme.tab`, `theme.win`, `theme.tail` (`tabline.lua:79-87`).
- `nerdfont = true` and `lualine_theme = ''` (`tabline.lua:88-90`).

Preset labels/separators are not arbitrary options:

- Tab labels are built in `preset_tab()` and include status icon, tab number/jump key, tab name, and close button (`tabline.lua:126-142`).
- Window labels are built in `preset_win()` and include current-window icon and `win.buf_name()` (`tabline.lua:144-157`).
- Head/tail text comes from `preset_head()` and `preset_tail()` (`tabline.lua:104-120`).

#### Buffer helper exists only for custom lines

- `line.bufs()` returns all listed buffers via `api.get_bufs()` (`lines.lua:58-63`; `api.lua:59-67`).
- `TabbyBufs.filter()` and `.foreach()` are available (`bufs.lua:100-119`).
- Current repo custom line uses this to render listed buffers:

```lua
local buffers = line.bufs().filter(function(buf)
  return is_tabline_buffer(buf.id)
end)
...
tabline[#tabline + 1] = buffers.foreach(function(buf, index)
  return buf_label(line, buf, index)
end)
```

Source: `C:\Users\alleg\AppData\Local\nvim\lua\plugins\bufferline.lua:209-230`.

No built-in preset implementation at `tabline.lua:176-266` uses `line.bufs()`.

#### Current repo custom offset pattern

Current repo manually detects the Snacks layout wrapper on the left and inserts a matching blank segment:

- Finds `snacks_layout_box` normal window at left screen column 0 (`bufferline.lua:132-140`).
- Builds offset blank + separator (`bufferline.lua:167-176`).
- Inserts offset before tabby head/tabs (`bufferline.lua:209-218`).

No equivalent `offsets = ...` or sidebar API was found in tabby docs/source.

### External References

- [nanozuki/tabby.nvim README on GitHub](https://github.com/nanozuki/tabby.nvim/blob/6362aa95/README.md) — External search confirmed the same preset setup form, option keys, and five preset names as local README/help.
- [nanozuki/tabby.nvim `lua/tabby/tabline.lua` on GitHub](https://github.com/nanozuki/tabby.nvim/blob/6362aa95/lua/tabby/tabline.lua) — External search confirmed current preset implementation patterns: `active_wins_at_tail`, `active_wins_at_end`, and `tab_only` use tabs/windows, not buffers.
- [DeepWiki: Using Presets for nanozuki/tabby.nvim](https://deepwiki.com/nanozuki/tabby.nvim/2.1-using-presets) — Secondary summary of the five preset layouts; used only as corroboration because local source/README are authoritative for this task.

### Related Specs

- `C:\Users\alleg\AppData\Local\nvim\.trellis\tasks\06-05-fix-bufferline-tabbar-visuals\prd.md` — Active task requires retaining explorer offset/non-overlap (`prd.md:17`) and keeping changes scoped to bufferline/UI highlighting/config (`prd.md:35`).
- `C:\Users\alleg\AppData\Local\nvim\.trellis\spec\frontend\component-guidelines.md` — Treats Neovim plugin UI config as the component-like surface; `lua/plugins/bufferline.lua` owns tabline appearance and buffer click behavior (`component-guidelines.md:9-16`).
- `C:\Users\alleg\AppData\Local\nvim\.trellis\spec\frontend\quality-guidelines.md` — Requires plugin-owned UI options/keymaps to stay local to plugin specs and preserves Snacks explorer offset expectations (`quality-guidelines.md:25-31`, `quality-guidelines.md:58-68`).
- `C:\Users\alleg\AppData\Local\nvim\.trellis\spec\frontend\directory-structure.md` — Locates plugin UI/keymaps under `lua/plugins/*.lua`; identifies `lua/plugins/bufferline.lua` as buffer tabline UI and buffer navigation mappings (`directory-structure.md:20-34`).

## Caveats / Not Found

- No tabby-native `offsets`, `sidebar`, or Snacks/NvimTree offset option was found in local tabby README, help, or source. The docs only show filtering windows such as NvimTree from custom window rendering (`README.md:565-573`; `doc\tabby.txt:613-621`).
- No current preset was found that renders `line.bufs()` or all listed buffers. Presets render tabs and windows/top windows.
- The term `layout` appears in legacy preset tables (`lua\tabby\presets.lua`), but current README/API uses `preset` names through `tabby.tabline.use_preset()`; the legacy `layout` fields should not be treated as the current high-level API.
- README/default visual interpretation has one ambiguity: source default and README example both point to `active_wins_at_tail`, while a README image filename under `active_wins_at_end` says `tabby-default-1.png`. The local runtime default remains `active_wins_at_tail`.
