# Commit Snacks Git Keymaps

## Goal

提交当前 `lua/plugins/snacks.lua` 中已经存在的 Snacks Git 快捷键整理与 lazygit 浮窗配置改动，让 Git 相关动作统一收敛到 `<leader>g` 前缀，并让 lazygit 使用更大的 rounded 浮窗。

## Requirements

- 将现有 Git 相关 Snacks 快捷键从 `<leader>s*` 系列迁移为 `<leader>g*` 系列。
- 增加 `<leader>g` Git 分组说明。
- 保留原有 Git picker 功能：branches、log、log line、status、stash、diff hunks、file log。
- 保留并提交新增 Git 功能入口：blame line、git files。
- 提交 `lazygit.win` 浮窗配置：`position = "float"`、`width = 0.95`、`height = 0.95`、`border = "rounded"`。
- 不修改 Snacks terminal、Claude Code、LSP picker、dashboard 等无关配置。

## Acceptance Criteria

- [ ] `lua/plugins/snacks.lua` 语法正确，可被 Neovim headless 加载。
- [ ] Git 相关 keymaps 使用 `<leader>g` 前缀并保留对应 Snacks 调用。
- [ ] lazygit 窗口配置存在于 `opts.lazygit.win`。
- [ ] 本次提交只包含 `lua/plugins/snacks.lua` 与当前 Trellis 任务记录。

## Definition of Done

- 复核 git diff，确认无其他代码文件混入。
- 运行可行的 Lua/Neovim 配置检查。
- 提交工作 commit。

## Technical Approach

使用当前工作树中已有的 `lua/plugins/snacks.lua` diff，不进行额外重构。验证通过后，只暂存并提交该文件和本任务目录。

## Decision (ADR-lite)

**Context**: 上一轮任务结束后，`lua/plugins/snacks.lua` 仍有任务外未提交改动；用户要求“这个也提交了”。

**Decision**: 将该改动作为独立 Trellis 任务提交，避免混入前一个 Claude terminal Esc 修复任务。

**Consequences**: Git keymaps 从 `<leader>s*` 改为 `<leader>g*`，原 `<leader>s*` Git 入口不再由此文件提供；lazygit 使用更接近全屏的浮窗。

## Out of Scope

- 不继续调整其他 Snacks 模块或 terminal 行为。
- 不修改 Claude Code 配置。
- 不新增额外 Git 命令或重新设计所有 keymap 前缀。
- 不提交与 `lua/plugins/snacks.lua` 无关的改动。

## Technical Notes

- 已检查当前 diff，改动集中在 `lua/plugins/snacks.lua` 的 Git keymaps 与 `opts.lazygit.win`。
- 该任务是对已存在工作树改动的独立提交与验证，不需要外部文档研究。
