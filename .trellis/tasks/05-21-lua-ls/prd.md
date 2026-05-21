# 优化 lua_ls 配置

## Goal

精简 `lua/lsp/lua_ls.lua` 中的模板注释，并按 nvim-lspconfig 对 Neovim Lua 配置的推荐补充 Lua module runtime path，让 lua-language-server 更准确地理解本仓库的 `require(...)` 模块加载路径。

## What I already know

* 当前 `lua_ls.lua` 已使用 `lsp.utils.is_mason_package_installed("lua-language-server")` 做 Mason package guard。
* 当前配置包含多段模板注释和已注释配置示例，实际维护价值低。
* nvim-lspconfig 文档推荐在 Neovim Lua 配置中设置 `runtime.path = { "lua/?.lua", "lua/?/init.lua" }`。
* 用户确认只做清理和小补强，不修改诊断屏蔽、formatter indent、workspace library 或 setup 行为。

## Requirements

* 在 `Lua.runtime` 中保留 `version = "LuaJIT"`。
* 在 `Lua.runtime` 中新增：
  * `path = { "lua/?.lua", "lua/?/init.lua" }`
* 删除无用模板注释和已注释配置示例。
* 保留以下配置不变：
  * `diagnostics.globals`
  * `diagnostics.disable`
  * `telemetry.enable = false`
  * `format.defaultConfig.indent_size = "4"`
  * `workspace.checkThirdParty = false`
  * `workspace.library = { vim.env.VIMRUNTIME }`
  * Mason helper guard 和 `vim.lsp.config/enable` 行为

## Acceptance Criteria

* [ ] `lua/lsp/lua_ls.lua` 包含 `runtime.path = { "lua/?.lua", "lua/?/init.lua" }`。
* [ ] 无旧模板注释或注释掉的 `completion` / runtimepath 示例残留。
* [ ] 诊断、telemetry、format、workspace library 和 setup 行为保持不变。
* [ ] Neovim headless 启动检查通过。
* [ ] diff 只包含预期 `lua_ls.lua` 配置清理和 runtime path 补充。

## Definition of Done

* 只修改 `lua/lsp/lua_ls.lua`。
* 运行 `nvim --headless "+luafile init.lua" "+qa"`。
* 运行 `git diff --check`。
* 检查 diff，确认没有改动 diagnostics disable 或 formatter indent。

## Technical Approach

直接编辑 `lua/lsp/lua_ls.lua`：在 `runtime` 表中加入 `path`，删除说明性模板注释和注释掉的示例配置，保留有效配置值。

## Decision (ADR-lite)

**Context**: 当前 `lua_ls.lua` 配置可用，但含有旧模板注释；同时缺少 nvim-lspconfig 推荐的 Lua module load path。

**Decision**: 做最小优化：清理注释并补 `runtime.path`。不调整诊断屏蔽和 formatter 缩进，因为这些可能反映既有偏好或需要单独验证。

**Consequences**: 配置更简洁，Lua LS 对 `lua/?.lua` 和 `lua/?/init.lua` 模块加载路径理解更准确；不会改变诊断噪音和格式化策略。

## Out of Scope

* 不删除 `diagnostics.disable`。
* 不调整 `diagnostics.globals`。
* 不改变 formatter `indent_size = "4"`。
* 不把 workspace library 扩展为完整 runtimepath。
* 不修改其他 LSP 模块。

## Technical Notes

* `lua/lsp/lua_ls.lua` 属于 backend/runtime LSP 配置。
* nvim-lspconfig 文档推荐 Neovim Lua 配置补充 `runtime.path` 以匹配 `:h lua-module-load`。
* `.trellis/spec/backend/quality-guidelines.md` 记录本仓库 Lua 缩进存在混合状态，不能在本任务中顺手统一 formatter 策略。
