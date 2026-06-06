# fix-bufferline-tabbar-visuals

## Goal

修正当前 `bufferline.nvim` 顶部 tabbar 的视觉效果：保留 snacks explorer 的 sidebar offset，避免 tabline 覆盖 Explorer，同时把顶部做成独立 tab bar，避免选中和未选中 tab 与编辑窗口背景连在一起。

## What I already know

* 用户反馈：删除 offset 后 tabline 会跑到 Explorer 上方，说明 offset 必须保留。
* 用户反馈：把 `fill` 改成 `Normal` 后虽然解决超出/色块问题，但 tabbar 与编辑窗口背景融合，视觉难看。
* 已查阅 `bufferline.nvim` 文档：sidebar 需要通过 `options.offsets` 防止 bufferline 绘制到文件树上方。
* 已查阅本地源码：offset 的 `separator` 使用 `offset_separator` 高亮；offset 区域 `highlight` 控制上方占位区域显示。
* 当前主题颜色：`Normal bg = #fbf1c7`，`TabLine bg = #e5d5ad`，`TabLineFill bg = #f2e5bc`，`WinSeparator fg = #d8cfa3`。

## Requirements

* 保留 `snacks_layout_box` offset，防止 bufferline 覆盖 Explorer。
* offset 区域不显示 `File Explorer` 文本，只作为左侧占位。
* 顶部 tabbar 使用独立背景色，不与编辑区 `Normal` 背景连在一起。
* 选中 tab、未选中 tab、tabbar fill、offset separator 有清晰但低对比度的层次。
* 继续隐藏空白区 `~`。
* 仅修改当前 Neovim 配置，不迁移 NvChad，不新增插件。

## Acceptance Criteria

* [ ] 打开 Explorer 时，bufferline 不覆盖 Explorer 顶部。
* [ ] Explorer 右侧不再出现突兀多余色块。
* [ ] 顶部 tabbar 与编辑窗口背景有视觉分层。
* [ ] 选中 tab 和未选中 tab 均不像直接连到下面窗口。
* [ ] `nvim --headless +qa` 无报错。

## Definition of Done

* Neovim 配置可正常启动。
* 改动范围控制在 bufferline/UI 高亮相关配置。
* 不引入新插件或大范围重构。

## Technical Approach

按 `bufferline.nvim` 文档配置：保留 sidebar `offsets`，同时显式设置 `highlights.fill`、`highlights.background`、`highlights.buffer_selected`、`highlights.separator`、`highlights.offset_separator` 等高亮。使用当前 gruvbox-material light 主题下的低对比色，构建一条独立但不刺眼的 tabbar。

## Decision (ADR-lite)

**Context**: 直接删除 offset 会导致 bufferline 覆盖 Explorer；把 fill 设置成 Normal 会导致 tabbar 与编辑区融为一体。

**Decision**: 保留 offset，并为 bufferline 设置独立 tabbar 色板。

**Consequences**: 当前方案针对浅色 gruvbox-material 优化；未来换成深色主题时可能需要把颜色抽象成按主题动态计算。

## Out of Scope

* 不切换主题。
* 不迁移到 NvChad UI。
* 不替换 `bufferline.nvim`。
* 不调整 lualine/statusline。

## Technical Notes

* 主要文件：`lua/plugins/bufferline.lua`
* 相关文件：`lua/core/autocmds.lua`、`lua/core/options.lua`
* 文档参考：本地 `nvim-data/lazy/bufferline.nvim/doc/bufferline.txt` 的 `bufferline-offset` 与 `bufferline-highlights`。
