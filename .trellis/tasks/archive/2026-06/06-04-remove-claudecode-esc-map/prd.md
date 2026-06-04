# Remove Claude Code Esc Terminal Mapping

## Goal

删除 `lua/plugins/claudecode.lua` 中 Claude Code terminal buffer 对 `<Esc>` 的 terminal-mode 映射，让 Claude Code 在自己的交互界面中优先接收 `Esc`，例如 MCP 菜单中的 `Esc to cancel`。

## Requirements

- 移除 Claude Code terminal buffer 内将 `<Esc>` 映射为 `<C-\><C-n>` 的自定义逻辑。
- 保持 `coder/claudecode.nvim` 插件声明和现有 `<leader>a*` 快捷键不变。
- 不额外新增替代按键，除非后续明确需要。

## Acceptance Criteria

- [ ] `lua/plugins/claudecode.lua` 不再为 Claude terminal 设置 terminal-mode `<Esc>` 映射。
- [ ] Claude Code 内部菜单/交互可以收到 `Esc`，不再被 Neovim 抢先转成 terminal normal mode。
- [ ] 现有 ClaudeCode 打开、聚焦、resume、continue、模型选择、发送、diff accept/deny 快捷键保持不变。

## Definition of Done

- 配置文件语法正确。
- 修改范围最小，无无关重构。
- 检查 git diff 确认只删除目标映射相关逻辑。

## Technical Approach

删除 `set_claude_terminal_esc_keymap` 函数和对应自动命令配置，保留插件 `setup(opts)` 与 Lazy keys。这样 `Esc` 将回落到终端/Claude Code/Snacks terminal 的默认处理。

## Decision (ADR-lite)

**Context**: 当前自定义映射拦截 Claude Code terminal 中的 `<Esc>`，导致 Claude Code MCP 管理界面无法用 `Esc` 取消。

**Decision**: 删除 Claude terminal 专属 `<Esc>` 拦截，不新增替代退出键。

**Consequences**: Claude Code 优先接收 `Esc`。如果之后仍需要从 Neovim terminal input 退回 normal mode，可使用 Neovim 原生 `<C-\><C-n>` 或另行添加非冲突快捷键。

## Out of Scope

- 不修改 Claude Code CLI 配置。
- 不修改 MCP server 配置。
- 不调整全局 terminal 行为或 Snacks terminal 默认行为。

## Technical Notes

- 已检查 `lua/plugins/claudecode.lua`，当前 `<Esc>` 映射位于 `set_claude_terminal_esc_keymap` 中。
- 已检查 `coder/claudecode.nvim` 的 terminal provider 代码：Snacks provider 会通过 `start_insert`/`auto_insert` 管理 terminal input，Snacks terminal 默认支持单次 Esc 传给终端、双 Esc 进入 normal 的行为。
