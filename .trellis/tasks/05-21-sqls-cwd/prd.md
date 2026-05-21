# 修复 sqls 配置 cwd 绑定

## Goal

修复 `lua/lsp/sqls.lua` 中 sqls 启动命令绑定 Neovim 启动目录的问题，避免从一个目录启动 Neovim 后打开其他项目 SQL 文件时错误读取启动目录下的 `.sqlsrc.yml`。

## What I already know

* 当前 `cmd` 是 `{ "sqls", "-config", vim.loop.cwd() .. "/.sqlsrc.yml" }`。
* 这会把 sqls 配置文件固定到 Neovim 启动时的 cwd，而不是 SQL 文件所属项目根目录。
* `root_markers = { "config.yml", ".sqlsrc.yml" }` 已经声明了项目根标记。
* nvim-lspconfig 文档允许显式传 `sqls -config path`，但当前固定 cwd 的方式不适合多项目场景。
* 用户同意采用最小修复：去掉 cwd 绑定，不抽象 Mason 检查逻辑，不修改其他 LSP 模块。

## Requirements

* 将 `lua/lsp/sqls.lua` 中的 `cmd` 改为 `{ "sqls" }`。
* 保留 `filetypes = { "sql", "mysql" }`。
* 保留 `root_markers = { "config.yml", ".sqlsrc.yml" }`。
* 清理该文件中的多余空行。
* 不抽象重复的 Mason 检查逻辑。
* 不修改其他 `lua/lsp/*.lua` 文件。

## Acceptance Criteria

* [ ] `lua/lsp/sqls.lua` 不再使用 `vim.loop.cwd()` / `vim.uv.cwd()` 拼接 `.sqlsrc.yml`。
* [ ] `sqls` 启动命令为 `{ "sqls" }`。
* [ ] `filetypes` 和 `root_markers` 保持不变。
* [ ] Neovim headless 启动检查通过。
* [ ] diff 只包含预期 sqls 配置最小修改。

## Definition of Done

* 只改 `lua/lsp/sqls.lua`。
* 运行 `nvim --headless "+luafile init.lua" "+qa"`。
* 运行 `git diff --check`。
* 检查 diff，确认没有引入不必要抽象或其他 LSP 行为变化。

## Technical Approach

直接编辑 `lua/lsp/sqls.lua`，移除 `-config` 参数和 `vim.loop.cwd()` 路径拼接，让 sqls 以默认命令启动，并继续依赖 root markers 提供项目上下文。

## Decision (ADR-lite)

**Context**: 固定使用 Neovim 启动目录下的 `.sqlsrc.yml` 会让 SQL LSP 配置受启动位置影响，不适合跨项目使用。

**Decision**: 改为 `cmd = { "sqls" }`，保留 root markers。暂不实现动态 root config path，因为当前需求是消除错误 cwd 绑定，而不是新增复杂配置查找逻辑。

**Consequences**: sqls 不再被错误绑定到启动目录；若某项目确实依赖显式 `-config` 参数，后续可基于实际需求实现 root-aware config path。

## Out of Scope

* 不新增 sqls root-aware `-config` 动态路径逻辑。
* 不抽取 Mason helper。
* 不修改 `lua/plugins/lspconfig.lua` 或其他 LSP 模块。
* 不新增通知或日志。

## Technical Notes

* `lua/lsp/sqls.lua` 属于 backend/runtime 层的 LSP 配置。
* `.trellis/spec/backend/index.md` 将 `lua/lsp/*.lua` 归入 backend 指南范围。
* nvim-lspconfig 文档显示 sqls 可使用 `cmd = { "sqls", "-config", "path/to/config.yml" }`，但当前固定 cwd 的 path 是问题来源。
