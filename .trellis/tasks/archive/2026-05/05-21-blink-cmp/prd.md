# 精简 blink.cmp 配置

## Goal

精简当前 Neovim 配置中的 `blink.cmp` 配置，删除与官方/本地默认值重复的冗余项，降低未来维护成本，同时保持用户现有补全行为不变。

## What I already know

* 用户已同意按前面的审查建议执行配置精简。
* 目标文件是 `lua/plugins/blink.lua`，属于补全、命令行补全和签名 UI 配置。
* 本任务只删除默认值重复项，不改变实际使用体验。
* 需要保留 `cmdline` 自动弹出菜单、当前 keymap 行为、当前 documentation 手动触发行为。

## Requirements

* 删除 `appearance.use_nvim_cmp_as_default = false`，因为它是默认值且本地源码提示未来会移除。
* 删除与默认值重复的 `completion.trigger` 配置。
* 删除默认的 `completion.keyword.range = "prefix"`。
* 删除默认的 `completion.accept.auto_brackets.enabled = true`。
* 删除默认的 `fuzzy.prebuilt_binaries` 配置段。
* 保留用户行为偏好：`cmdline.completion.menu.auto_show = true`、`keymap.preset = "enter"`、自定义 `<Tab>/<S-Tab>`、`preselect = false`、`menu.draw.columns`、`sources.providers.cmdline.min_keyword_length`、`signature.enabled = true`。

## Acceptance Criteria

* [ ] `lua/plugins/blink.lua` 不再包含上述冗余默认配置。
* [ ] `cmdline` 自动弹出菜单行为保持不变。
* [ ] 插件 spec 仍返回有效 lazy.nvim 配置。
* [ ] Neovim headless 启动检查通过。

## Definition of Done

* 只修改必要配置，不新增抽象、不改变插件行为。
* 运行 headless 启动检查：`nvim --headless "+luafile init.lua" "+qa"`。
* 检查 git diff，确认变更只涉及预期配置精简。

## Technical Approach

直接编辑 `lua/plugins/blink.lua`，删除可由 `blink.cmp` 默认值提供的配置项；保留所有体现用户偏好的非默认配置。

## Decision (ADR-lite)

**Context**: 当前配置可用，但包含多处与 `blink.cmp` 默认值重复的字段，其中 `appearance.use_nvim_cmp_as_default` 还被源码标注未来会移除。

**Decision**: 采用最小行为保持方案：只删除默认值重复项，不改变 cmdline、documentation、keymap、selection 等用户体验设置。

**Consequences**: 配置更短、更贴近官方默认；未来插件升级时维护压力更低。风险是默认值若在上游未来变化，删除后的行为会跟随上游默认变化，但本次删除项都是当前稳定默认或不推荐显式保留项。

## Out of Scope

* 不启用 documentation 自动显示。
* 不改变 `cmdline.completion.menu.auto_show = true`。
* 不调整 keymap、selection、sources 顺序或补全展示布局。
* 不修改其他插件配置。

## Technical Notes

* `lua/plugins/blink.lua` 是本仓库 completion / cmdline completion / signature UI 配置位置。
* `.trellis/spec/frontend/directory-structure.md` 要求插件 UI 配置保留在 `lua/plugins/*.lua`。
* `.trellis/spec/frontend/quality-guidelines.md` 要求 UI/config 变更后运行 headless startup check。
* `.trellis/spec/guides/code-reuse-thinking-guide.md` 要求先检索、避免无意义新增代码；本任务仅删除冗余配置。
