# 替换 bufferline bufdelete 依赖

## Goal

将 `lua/plugins/bufferline.lua` 中未实际发挥作用的 `famiu/bufdelete.nvim` 依赖替换为项目已启用的 `snacks.nvim` `Snacks.bufdelete`，减少插件依赖并保持现有 Bufferline 关闭 buffer 的使用语义。

## What I already know

* 用户询问 `famiu/bufdelete.nvim` 是否能换成 `snacks.nvim` 的 bufdelete，并已确认可以替换。
* `lua/plugins/bufferline.lua` 当前声明依赖 `famiu/bufdelete.nvim`。
* 当前实际关闭行为使用 `bdelete!` / `bdelete` 命令，而不是显式调用 `famiu/bufdelete.nvim` API。
* `lua/plugins/snacks.lua` 已配置 `folke/snacks.nvim` 且 `lazy = false`，所以全局 `Snacks` API 在正常插件配置场景下可用。
* Snacks 文档提供 `Snacks.bufdelete()`、`Snacks.bufdelete.delete(opts)`、`Snacks.bufdelete.all(opts)`、`Snacks.bufdelete.other(opts)`，用途是删除 buffer 且不破坏窗口布局。

## Assumptions (temporary)

* 修改 `lua/plugins/bufferline.lua` 和 `lua/plugins/snacks.lua`。
* `<leader>bd` 保持“关闭当前 buffer”的语义，但归属 `snacks.nvim` 的 keymap 配置。
* Bufferline 鼠标关闭行为继续保持原来的 force close 语义。

## Open Questions

* 无。

## Requirements

* 移除 `famiu/bufdelete.nvim` 依赖。
* `close_command` 改为调用 `Snacks.bufdelete({ buf = bufnr, force = true })`。
* `right_mouse_command` 改为调用 `Snacks.bufdelete({ buf = bufnr, force = true })`。
* `<leader>bd` 在 `lua/plugins/snacks.lua` 中调用 `Snacks.bufdelete()`，保持关闭当前 buffer 的非 force 语义。
* 不改变现有 Bufferline 其他 keymaps、排序、样式和事件加载策略。

## Acceptance Criteria

* [ ] `lua/plugins/bufferline.lua` 不再引用 `famiu/bufdelete.nvim`。
* [ ] Bufferline close/right-click close 使用 `Snacks.bufdelete` 删除指定 buffer。
* [ ] `<leader>bd` 在 `lua/plugins/snacks.lua` 使用 `Snacks.bufdelete()` 删除当前 buffer。
* [ ] Neovim headless 配置加载通过。
* [ ] Bufferline 插件强制加载检查通过。

## Definition of Done

* 变更符合 lazy.nvim plugin spec 结构。
* 不引入新的插件依赖。
* 不创建重复 helper 或额外抽象。
* 运行可用的 Neovim headless 检查。

## Technical Approach

在 `lua/plugins/bufferline.lua` 内使用函数形式的 `close_command` / `right_mouse_command` 调用 `Snacks.bufdelete` 删除指定 buffer；在 `lua/plugins/snacks.lua` 内声明 `<leader>bd`，让通用 buffer 删除 keymap 归属 Snacks。由于 `snacks.nvim` 已 `lazy = false`，不需要让 Bufferline 依赖 Snacks。

## Decision (ADR-lite)

**Context**: 当前 `famiu/bufdelete.nvim` 只是作为依赖存在，但关闭 buffer 的实际命令仍是内置 `:bdelete` / `:bdelete!`，没有获得 layout-preserving 删除能力。

**Decision**: 使用已安装并 eager-loaded 的 `Snacks.bufdelete` 替换关闭行为，并移除 `famiu/bufdelete.nvim` 依赖。

**Consequences**: 减少一个插件依赖；buffer 删除逻辑集中到 Snacks；如果未来移除 Snacks，需要同步替换 Bufferline 删除调用。

## Out of Scope

* 不新增 buffer 删除相关快捷键。
* 不调整 Bufferline 样式、排序或诊断显示。
* 不修改 `lua/plugins/snacks.lua` 中除 `<leader>bd` keymap 归属外的配置。
* 不更新 lazy-lock，除非实际插件同步产生变化。

## Technical Notes

* 目标文件：`lua/plugins/bufferline.lua`
* 相关文件：`lua/plugins/snacks.lua`
* Snacks bufdelete 文档确认 `Snacks.bufdelete()` 默认删除当前 buffer，`Snacks.bufdelete({ buf = bufnr, force = true })` 可删除指定 buffer。
