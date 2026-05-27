# 用 Snacks terminal 替换 ToggleTerm

## Goal

用项目已启用的 `snacks.nvim` `Snacks.terminal` 替换 `akinsho/toggleterm.nvim`，减少终端插件依赖，同时按 Snacks count 模型保留终端交互：`<C-\>` toggle、`<leader>tn` 创建下一个编号终端、`<leader>ts` 选择已有终端，以及 Windows shell 和 terminal-mode 导航体验。

## What I already know

* 用户已确认可以用 Snacks terminal 替换 ToggleTerm。
* 用户明确要求 `<leader>ts` 需要保留“选择已有 terminal”的能力。
* 当前 `lua/plugins/toggleterm.lua` 配置了 Windows PowerShell shell 选项、terminal-mode keymaps、`<leader>t` group、`<leader>tn`、`<leader>ts`、`<C-\>` toggle、horizontal 方向和 size 10。
* 当前 `lua/plugins/snacks.lua` 已启用 `folke/snacks.nvim`，并且 `lazy = false`。
* Snacks terminal 提供 `Snacks.terminal.toggle/open/list/focus`，可按 `cmd/cwd/env/count` 区分终端。
* 当前项目还有 `lua/plugins/claudecode.lua` 管理 Claude Code terminal 的 `<Esc>` 行为，所以终端模式映射不能使用宽泛 `TermOpen term://*`，必须限制在 Snacks terminal。
* `lua/plugins/overseer.lua` 当前使用 `strategy = { "toggleterm", direction = 'vertical' }`，删除 ToggleTerm 前必须同步处理。

## Assumptions (temporary)

* 删除 `lua/plugins/toggleterm.lua` 或至少移除 `akinsho/toggleterm.nvim` 插件 spec。
* Windows shell 选项应迁移到非 ToggleTerm 依赖的位置，避免删插件后丢失。
* Snacks terminal 的默认底部分屏可替代当前 `direction = 'horizontal'`。
* `<leader>tn` 基于 `Snacks.terminal.list()` 中现存 terminal 的最大 id 创建/切换下一个编号，不维护持久自增变量。

## Open Questions

* 无。

## Requirements (evolving)

* 移除 `akinsho/toggleterm.nvim` 依赖/配置。
* 用 `Snacks.terminal.toggle` 替代 `<C-\>` toggle 终端。
* 多终端按 Snacks count 模型工作：`<C-\>` 切换 1 号，`<leader>tn` 根据现存 terminal 最大 id 创建/切换下一个编号终端。
* 用 `Snacks.terminal.list()` + `vim.ui.select()` 实现 `<leader>ts` 选择已有终端。
* 保留 `<leader>t` Terminal group 和现有 keymap 描述语义。
* 保留 Windows shell 配置能力，不能因删除 ToggleTerm 失效。
* terminal-mode keymaps 只作用于 Snacks terminal，不污染 Claude Code terminal 或其他普通 terminal。
* 将 `lua/plugins/overseer.lua` 的 strategy 从 `toggleterm` 改为 `jobstart`。

## Acceptance Criteria (evolving)

* [ ] `lua/plugins/toggleterm.lua` 不再注册 `akinsho/toggleterm.nvim`。
* [ ] `<C-\>` 使用 Snacks terminal toggle。
* [ ] `<leader>tn` 能基于现存 Snacks terminal 最大 id 创建/切换下一个编号 terminal。
* [ ] `<leader>ts` 能从已有 Snacks terminal 中选择并 focus。
* [ ] Windows shell 配置仍在启动时生效。
* [ ] Snacks terminal 中可用 `<Esc>`/`jk`/`<C-h/j/k/l>` 导航体验，且不影响 Claude Code terminal。
* [ ] Neovim headless 配置加载通过。
* [ ] Snacks terminal 相关函数加载检查通过。
* [ ] `lua/plugins/overseer.lua` 使用 `jobstart` strategy，不再引用 ToggleTerm strategy。

## Definition of Done

* 不引入新的插件依赖。
* 不创建与现有 Snacks/terminal 逻辑重复的大型抽象。
* 不修改 Claude Code terminal 行为。
* 运行可用的 Neovim headless 检查。

## Out of Scope

* 不实现 ToggleTerm 完整 API 兼容层。
* 不迁移 ToggleTerm 的高级回调能力如 on_stdout/on_stderr/on_exit。
* 不新增复杂 terminal session 持久化。
* 不调整 DAP terminal 行为。

## Technical Approach

* 将通用 Windows shell 选项迁移到不依赖 ToggleTerm plugin spec 的位置。
* 将终端 keymaps 和 Snacks terminal 配置放到 `lua/plugins/snacks.lua`，包括 `<C-\>`、`<leader>tn`、`<leader>ts` 和 Snacks terminal 专属 terminal-mode mappings。
* `<C-\>` 依赖 Snacks 内置的 `vim.v.count1` 识别指定编号；`<leader>tn` 临时计算当前最大 terminal id 后使用 `max + 1`，不维护本地递增 count。
* `<leader>ts` 使用 `vim.ui.select(Snacks.terminal.list(), ...)`，选中后 `term:show():focus()`。
* 将 Overseer strategy 改成 `jobstart`，彻底移除对 ToggleTerm 的运行时依赖。

## Decision (ADR-lite)

**Context**: ToggleTerm 当前同时提供普通终端 UI 和 Overseer strategy，但 Snacks 已能覆盖普通终端 toggle/new/select；Overseer 的 ToggleTerm strategy 会阻止移除插件依赖。

**Decision**: 用 Snacks terminal 接管普通终端交互，并以 Snacks count 模型管理编号终端；Overseer 改用 `jobstart` strategy；终端模式映射只绑定到 Snacks terminal buffer。

**Consequences**: 终端插件依赖减少；Overseer 任务输出不再使用 ToggleTerm 窗口；如果未来需要更丰富的 task UI，可单独调整 Overseer strategy。

## Technical Notes

* 目标文件候选：`lua/plugins/toggleterm.lua`、`lua/plugins/snacks.lua`、`lua/plugins/overseer.lua`。
* 相关文件：`lua/plugins/claudecode.lua`。
* Snacks terminal docs: `Snacks.terminal.toggle/open/list/focus`，默认无 cmd 为 bottom split，有 cmd 为 float；terminal id 由 `cmd`/`cwd`/`env`/`count` 组成，未传 `opts.count` 时使用 `vim.v.count1`。

## Research References

* [`research/snacks-terminal-toggleterm.md`](research/snacks-terminal-toggleterm.md) — Snacks terminal 可覆盖普通终端 toggle/new/select，但需要处理 Windows shell、Snacks terminal 专属 keymaps 和 Overseer 的 ToggleTerm strategy 引用。
