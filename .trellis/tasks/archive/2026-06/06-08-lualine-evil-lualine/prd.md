# 配置 lualine 并试用 evil_lualine

## Goal

将现有 `nvim-lualine/lualine.nvim` 配置从仅设置 `gruvbox-material` 主题，调整为可实际试用的 `evil_lualine` / Eviline 风格状态栏，同时尽量保持本仓库现有 lazy.nvim 插件结构和 gruvbox-material 视觉一致性。

## What I already know

* 用户希望参考官方文档 `https://github.com/nvim-lualine/lualine.nvim` 配置 lualine，并试一下 `evil_lualine`。
* 当前仓库已有 `lua/plugins/lualine.lua`，使用 lazy.nvim 插件 spec，依赖 `nvim-tree/nvim-web-devicons`，目前只配置 `options.theme = "gruvbox-material"`。
* 当前仓库通过 `lua/config/lazy.lua` 的 `{ import = "plugins" }` 自动加载 `lua/plugins/*.lua`。
* 当前主题插件是 `sainnhe/gruvbox-material`，并设置 `vim.o.background = "light"`、`gruvbox_material_background = "medium"`。
* `lua/core/options.lua` 已设置 `opt.showmode = false`、`opt.laststatus = 3`，适合 lualine 接管 mode 显示并使用全局 statusline。
* 当前 tabline 已由 `lua/plugins/bufferline.lua` 的 `nanozuki/tabby.nvim` 负责；本任务只改 statusline，不改 tabline/bufferline。
* `.trellis/spec/frontend/directory-structure.md` 明确 `lua/plugins/lualine.lua` 是 statusline theme/options owner。
* `.trellis/spec/frontend/component-guidelines.md` 要求插件 UI 配置优先保持在对应 `lua/plugins/<plugin>.lua`，能 declarative 配置时优先使用 `opts`。

## Assumptions (temporary)

* MVP 目标是“可试用 evil_lualine 风格”，不是引入独立第三方主题包或大规模重构 UI。
* 只需要修改 `lua/plugins/lualine.lua`；如果运行验证导致 lazy lock 自动变化，再按实际结果处理。
* 状态栏应与当前 light gruvbox-material 背景协调，而不是完全照搬官方 dark evil_lualine 配色。

## Open Questions

* 已确认：采用 gruvbox-material 适配版 Eviline。

## Requirements (evolving)

* 在 `lua/plugins/lualine.lua` 中实现 evil_lualine/Eviline 风格状态栏。
* 保持 lazy.nvim 插件 spec 的单文件配置方式。
* 不修改 tabby/bufferline 的 tabline 行为。
* 保留/恢复 lualine 常用信息：mode、file name、git branch/diff、diagnostics、encoding/fileformat/filetype、progress/location，按 evil_lualine 风格重新排布。
* 窄窗口或空 buffer 下不要显示过多噪音组件。

## Acceptance Criteria (evolving)

* [ ] `lua/plugins/lualine.lua` 加载无 Lua 语法错误。
* [ ] Headless `nvim --headless "+Lazy! sync" +qa` 或等效检查不因配置报错。
* [ ] lualine 状态栏启用 evil_lualine 风格：扁平分隔符、mode 色块/图标、左右组件分组。
* [ ] 现有 tabby tabline 不被本次改动替换或禁用。
* [ ] 无未使用调试输出、临时文件或无关改动。

## Definition of Done (team quality bar)

* Tests/checks added or updated where appropriate；本任务以 Neovim headless 加载检查为主。
* Lint/typecheck/CI green；若项目没有专门 lint，则记录已执行的 Neovim 配置加载检查。
* Docs/notes updated if behavior changes；本任务通过 PRD/research 记录实现决策。
* Rollout/rollback considered；回滚应只需恢复 `lua/plugins/lualine.lua`。

## Research References

* [`research/lualine-evil-style.md`](research/lualine-evil-style.md) — 已整理 lualine.nvim 官方配置选项、official `examples/evil_lualine.lua` / Eviline 风格、可比配置案例，以及映射到本仓库 lazy.nvim spec 的最小改动方式。

## Research Notes

### What similar tools do

* lualine 默认配置使用 `A | B | C ... X | Y | Z` 六段布局，默认显示 mode、branch、diff、diagnostics、filename、encoding、fileformat、filetype、progress、location。
* official `evil_lualine.lua` 通过禁用 separators、使用手写 palette、清空默认 `a/b/y/z`、将组件插入 `lualine_c` 和 `lualine_x`，形成扁平 Eviline 状态栏。
* LazyVim 等 lazy.nvim 配置常用 `opts = function()` 构造动态配置，但本仓库当前 lualine 文件更适合保持本地单文件 helpers + `opts`。

### Constraints from our repo/project

* lualine 配置归属 `lua/plugins/lualine.lua`。
* 当前色彩体系是 light `gruvbox-material`；官方 evil_lualine 示例是 dark palette，直接照搬可能与当前主题割裂。
* `laststatus = 3` 已在 core options 中启用，lualine 可显式 `globalstatus = true` 或跟随 `vim.o.laststatus == 3`。

### Feasible approaches here

**Approach A: gruvbox-material 适配版 Eviline（Recommended）**

* How it works: 保留 official evil_lualine 的结构和组件思路，但使用当前 gruvbox-material light palette 调整 `theme`、mode 颜色、diagnostics/git 颜色。
* Pros: 与当前主题一致，可长期保留；实现范围集中在 `lua/plugins/lualine.lua`。
* Cons: 不是 100% 官方示例原样截图，需要根据现有主题做取舍。

**Approach B: 官方 evil_lualine 原样试用**

* How it works: 尽量照搬官方 `examples/evil_lualine.lua` 的 dark palette、图标和组件布局。
* Pros: 最接近“试一下 evil_lualine”原始效果。
* Cons: 当前 Neovim 使用 light gruvbox-material，状态栏可能明显突兀；后续很可能还要再调色。

**Approach C: 极简 evil_lualine 结构**

* How it works: 只启用扁平 separators + 少量核心组件，不加入文件大小、LSP 名称、lazy updates 等丰富信息。
* Pros: 改动少、稳定、低噪音。
* Cons: 体验不像完整 Eviline，试用价值偏低。

## Expansion Sweep

### Future evolution

* 后续可能把 statusline palette 抽到共享 UI palette，但本任务先不做，避免过度设计。
* 后续可加入 lsp progress、dap status、lazy updates 等动态状态，但 MVP 只保留必要组件。

### Related scenarios

* tabline 已由 tabby 管理，本任务不改变 buffer tabbar 交互。
* Snacks dashboard/picker/input 等特殊 filetype 可能不适合显示完整 statusline，可通过 `disabled_filetypes` 或组件条件控制。

### Failure & edge cases

* 无 git 仓库、空 buffer、窄窗口、无 LSP client、无 devicons 字体时不能报错。
* 图标依赖 patched font；若字体不支持，只影响显示，不应影响启动。

## Decision (ADR-lite)

**Context**: 用户要试用 `evil_lualine`，但当前仓库已有 light gruvbox-material 主题和 tabby tabline。

**Decision**: 采用 Approach A：gruvbox-material 适配版 Eviline。保留 official evil_lualine 的扁平结构、mode 色块/图标、左右组件分组，并使用当前 light gruvbox-material 配色适配。

**Consequences**: 状态栏会比官方 dark 示例更融入当前配置；如果未来想临时对比官方原样效果，可再单独切换 palette。

## Out of Scope

* 不替换或删除 `nanozuki/tabby.nvim` tabline。
* 不改 `lua/core/mappings.lua`、窗口 resize 映射或 VS Code/Neovide 配置。
* 不引入新的 lualine 第三方主题包。
* 不做全局 UI palette 抽象或大规模主题系统重构。

## Technical Notes

* Inspected `lua/plugins/lualine.lua` — 当前 lualine 插件 spec 和旧注释组件。
* Inspected `lua/config/lazy.lua` — 确认 lazy.nvim 自动加载插件目录。
* Inspected `lua/plugins/themes.lua` — 确认 gruvbox-material light 主题配置。
* Inspected `lua/plugins/bufferline.lua` — 确认 tabline 由 tabby 管理，本任务不触碰。
* Inspected `lua/core/options.lua` — 确认 `showmode=false`、`laststatus=3`。
* Read lualine official docs via Context7: default config、component options、custom theme、global options。
* Research persisted at `research/lualine-evil-style.md`.
