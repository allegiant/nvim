# 抽取 LSP Mason 检查 helper

## Goal

抽取 `lua/lsp/*.lua` 中重复的 Mason package 安装检查逻辑，减少重复并保持各 LSP 模块的 setup 行为清晰，同时补齐 `vue_ls.lua` 对 `vtsls` 的安装检查。

## What I already know

* `jsonls.lua`、`lua_ls.lua`、`pylsp.lua`、`sqls.lua`、`vue_ls.lua` 都重复了 `pcall(require, "mason-registry")` 和 `mason_registry.is_installed(...)` guard。
* 重复调用点已达到 5 处，符合项目 code reuse guide 中 3+ 次重复可抽象的标准。
* `lua/core/utils.lua` 当前承载通用 table、notify、OS 判断工具；Mason package 检查是 LSP 专用逻辑，放进 `lua/lsp/utils.lua` 更合适。
* `vue_ls.lua` 同时启用 `vtsls` 和 `vue_ls`，但当前只检查了 `vue-language-server` 是否安装；本地 Mason 包存在 `vtsls`。
* nvim-lspconfig 文档推荐 Vue LS 需要配合 TypeScript server（当前使用 `vtsls` + `@vue/typescript-plugin` 的方向正确）。

## Requirements

* 新增 `lua/lsp/utils.lua`，提供 `is_mason_package_installed(package_name)`。
* helper 只封装 Mason registry require 和 `is_installed` 检查；缺失 Mason 或未安装 package 时返回 `false`。
* 将以下模块的重复 Mason guard 替换为 helper 调用：
  * `lua/lsp/jsonls.lua`
  * `lua/lsp/lua_ls.lua`
  * `lua/lsp/pylsp.lua`
  * `lua/lsp/sqls.lua`
  * `lua/lsp/vue_ls.lua`
* `vue_ls.lua` 需要同时检查 `vue-language-server` 和 `vtsls`。
* 不抽象 `setup_if_installed(...)` 这类高阶封装。
* 不修改 `lua/plugins/lspconfig.lua`。
* 不改变各 LSP 的 `vim.lsp.config(...)` / `vim.lsp.enable(...)` 行为。

## Acceptance Criteria

* [ ] `lua/lsp/utils.lua` 存在并只提供薄的 Mason package 检查 helper。
* [ ] 5 个 LSP 模块不再直接调用 `pcall(require, "mason-registry")`。
* [ ] 每个 LSP 模块仍在对应 package 缺失时直接 `return`。
* [ ] `vue_ls.lua` 检查 `vue-language-server` 和 `vtsls` 后才启用两个 server。
* [ ] Neovim headless 启动检查通过。
* [ ] diff 不包含 LSP setup 结构重构或自动发现逻辑。

## Definition of Done

* 运行 `nvim --headless "+luafile init.lua" "+qa"`。
* 运行 `git diff --check`。
* 搜索确认 LSP 模块中没有重复 Mason registry require。
* 检查 diff，确认未修改 `lua/plugins/lspconfig.lua`。

## Technical Approach

新增 `lua/lsp/utils.lua`，返回 `M` 模块并实现：

```lua
M.is_mason_package_installed = function(package_name)
  local present, mason_registry = pcall(require, "mason-registry")
  if not present then
    return false
  end

  return mason_registry.is_installed(package_name)
end
```

各 LSP 模块在文件顶部引入 `local lsp_utils = require("lsp.utils")`，在 `M.setup` 中使用 `if not lsp_utils.is_mason_package_installed("...") then return end`。

## Decision (ADR-lite)

**Context**: Mason 检查逻辑在 5 个 LSP 模块重复，且未来如果 Mason API 或错误处理策略变化会产生多处修改。

**Decision**: 抽取一个 LSP 专用的薄 helper 到 `lua/lsp/utils.lua`。不放入 `lua/core/utils.lua`，避免扩大 core 工具语义；不抽象 server setup，避免隐藏 `vue_ls.lua` 的双 server 特例。

**Consequences**: 重复代码减少，LSP 模块仍保持显式可读。新增一个 LSP 专用工具模块，后续 LSP server 可复用该安装检查。

## Out of Scope

* 不新增自动 LSP 模块发现。
* 不修改 `lua/plugins/lspconfig.lua`。
* 不重构 `vim.lsp.config(...)` / `vim.lsp.enable(...)` 调用。
* 不新增用户通知或日志。
* 不修改非 Mason guard 相关配置。

## Technical Notes

* `lua/lsp/*.lua` 属于 backend/runtime 层。
* `.trellis/spec/backend/directory-structure.md` 要求 LSP server setup 放在 `lua/lsp/<server>.lua` 并从 `lua/plugins/lspconfig.lua` 调用。
* `.trellis/spec/backend/error-handling.md` 要求 Mason 或 language server 不存在时 LSP 模块不要破坏启动。
* `.trellis/spec/guides/code-reuse-thinking-guide.md` 明确 3+ 次相同逻辑适合抽象。
