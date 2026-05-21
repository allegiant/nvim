# 优化 conform.nvim 配置

## Goal

让 `lua/plugins/conform.lua` 更贴近当前 conform.nvim 推荐配置，去掉旧的 `lsp_fallback` 写法，并移除过窄且依赖当前工作目录的 `prettierd.condition`。

## What I already know

* 当前 `format_on_save` 使用 `lsp_fallback = true`，conform.nvim 源码会兼容转换为 `lsp_format = "fallback"`，但当前文档推荐直接使用 `lsp_format = "fallback"`。
* 当前 `prettierd.condition` 只检查当前 cwd 下 `.prettierrc.js` 和 `.prettierrc.mjs`。
* conform.nvim 内置 `prettierd` 已支持递归识别 `.prettierrc` 和 `package.json` 中的 `prettier` 字段，并会忽略仅声明 prettier dependency 的场景。
* 当前仓库没有为 `json/jsonc` 配外部 formatter，保留 LSP fallback 对 jsonls formatter 的使用。

## Requirements

* 将 `format_on_save.lsp_fallback = true` 改为 `format_on_save.lsp_format = "fallback"`。
* 删除自定义 `formatters.prettierd.condition` 配置。
* 保留 `default_format_opts.lsp_format = "fallback"`。
* 保留 `formatters_by_ft` 中现有 filetype 和 formatter 列表。
* 保留 `<leader>fm` keymap 行为。
* 不新增 `json/jsonc` formatter。
* 不调整 `sql = { "sqruff" }`。

## Acceptance Criteria

* [ ] `lua/plugins/conform.lua` 不再包含 `lsp_fallback`。
* [ ] `lua/plugins/conform.lua` 不再覆盖 `prettierd.condition`。
* [ ] `default_format_opts`、`formatters_by_ft`、keymap 保持现有语义。
* [ ] Neovim headless 启动检查通过。
* [ ] diff 只包含预期 conform 配置更新。

## Definition of Done

* 只修改 `lua/plugins/conform.lua`。
* 运行 `nvim --headless "+luafile init.lua" "+qa"`。
* 运行 `git diff --check`。
* 检查 diff，确认没有扩大 formatter scope。

## Technical Approach

直接编辑 `lua/plugins/conform.lua`：把 `format_on_save` 表中的 `lsp_fallback` 替换为 `lsp_format`，并删除整个 `formatters.prettierd.condition` override，让 conform.nvim 使用内置 prettierd config detection。

## Decision (ADR-lite)

**Context**: 当前配置可以工作，但 `lsp_fallback` 是兼容旧写法，`prettierd.condition` 会限制内置更完整的 prettier config 检测。

**Decision**: 使用 conform.nvim 当前推荐的 `lsp_format = "fallback"`，并删除自定义 prettierd condition。

**Consequences**: 配置更符合当前文档；prettierd 会支持更多标准 prettier 配置文件和基于 buffer 的递归查找。若项目没有 prettier 配置，内置逻辑仍会避免错误启用 prettierd。

## Out of Scope

* 不新增 Python formatter。
* 不新增 JSON formatter。
* 不调整 SQL formatter。
* 不修改 LSP 配置。
* 不改变 keymap。

## Technical Notes

* `lua/plugins/conform.lua` 属于 editor-facing plugin config。
* conform.nvim 文档推荐 `format_on_save = { timeout_ms = 500, lsp_format = "fallback" }`。
* conform.nvim 内置 prettierd 测试覆盖 `.prettierrc` 递归查找和 `package.json` prettier 字段。
