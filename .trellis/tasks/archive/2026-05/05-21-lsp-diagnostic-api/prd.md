# 更新 LSP diagnostic 跳转 API

## Goal

更新 `lua/plugins/lspconfig.lua` 中已 deprecated 的 diagnostic 跳转 API，保持现有 `gj` / `gk` 键位体验，避免未来 Neovim 版本升级时出现弃用警告或兼容性问题。

## What I already know

* `lua/plugins/lspconfig.lua` 当前使用 `vim.diagnostic.goto_next()` 和 `vim.diagnostic.goto_prev()`。
* Neovim 0.11 文档标记这两个 API 已 deprecated，推荐使用 `vim.diagnostic.jump({ count = 1/-1, float = true })`。
* 用户确认连续的 `require("lsp.xxx").setup()` 不需要优化或重构。

## Requirements

* 将 `gj` 的实现从 `vim.diagnostic.goto_next()` 更新为 `vim.diagnostic.jump({ count = 1, float = true })`。
* 将 `gk` 的实现从 `vim.diagnostic.goto_prev()` 更新为 `vim.diagnostic.jump({ count = -1, float = true })`。
* 保留现有键位 `gj` / `gk` 和描述文本。
* 不优化、不循环化、不自动发现 `require("lsp.xxx").setup()`。
* 不重构 LSP 模块加载结构。

## Acceptance Criteria

* [ ] `lua/plugins/lspconfig.lua` 不再引用 `vim.diagnostic.goto_next()` / `goto_prev()`。
* [ ] `gj` / `gk` 仍然导航到下一个 / 上一个 diagnostic，并打开 diagnostic float。
* [ ] Neovim headless 启动检查通过。
* [ ] diff 只包含预期 API 替换和必要格式清理。

## Definition of Done

* 保持最小变更，不新增 helper、不改变 LSP server setup 列表。
* 运行 `nvim --headless "+luafile init.lua" "+qa"`。
* 运行 `git diff --check`。

## Technical Approach

直接编辑 `lua/plugins/lspconfig.lua` 的 `keys` 表，将两个 deprecated diagnostic navigation 调用替换为 `vim.diagnostic.jump(...)`。

## Decision (ADR-lite)

**Context**: Neovim 0.11 弃用了 `vim.diagnostic.goto_next()` / `goto_prev()`。

**Decision**: 使用官方推荐的 `vim.diagnostic.jump({ count = 1/-1, float = true })`，保持原键位和用户体验。

**Consequences**: 配置兼容当前推荐 API；变更范围小。暂不抽象 LSP setup，避免为 5 个显式配置引入不必要间接层。

## Out of Scope

* 不改 LSP server setup 列表。
* 不抽取 Mason helper。
* 不调整 diagnostic signs、virtual text、float border 或其他 keymap。
* 不修改 `lua/lsp/*.lua`。

## Technical Notes

* `lua/plugins/lspconfig.lua` 是 LSP 插件 spec 和 diagnostic keymap 所在文件。
* `.trellis/spec/frontend/directory-structure.md` 说明 `lua/plugins/lspconfig.lua` 可承载 LSP navigation/actions。
* `.trellis/spec/frontend/quality-guidelines.md` 要求 UI/config 变更后运行 headless startup check。
* `.trellis/spec/frontend/component-guidelines.md` 要求插件配置保持 declarative lazy.nvim spec 形态。
