# Upgrade blink.cmp to v2

## Goal

将 `blink.cmp` 从 v1.10.2（`version = "1.*"`）升级到 v2（跟踪 main），按官方 UPGRADE/Installation 做最小配置改动，保留现有补全行为。

## Requirements

* 移除 `version = "1.*"`，跟踪 main（v2）
* 为 `blink.cmp` 显式声明依赖 `saghen/blink.lib`
* 增加 `build = function() require('blink.cmp').build():pwait(60000) end`
* `fuzzy.implementation`：`prefer_rust_with_warning` → `rust`
* 保留现有 keymap / completion / cmdline / sources / signature 自定义
* 不改 `fluttertools.lua`（除非升级后 API 报错）
* 不改 `blink.pairs`

## Acceptance Criteria

* [x] `lua/plugins/blink.lua` 含 v2 必改项（无 `1.*` pin、有 blink.lib、有 build、fuzzy=rust）
* [x] 其余用户自定义 opts 行为保持
* [x] 用户本地 Lazy sync / build 成功；setup 无 unknown field；P0 优化已落地

## Definition of Done

* 配置变更集中在 `lua/plugins/blink.lua`
* 无废弃 opts / 无多余依赖
* PRD 记录破坏性变更与自测清单

## Technical Approach

最小 diff 升级：只改插件声明 + fuzzy.implementation，其余 opts 原样迁移。

## Decision (ADR-lite)

**Context**: 用户确认需要升级；先对照文档明确改动点。  
**Decision**: 跟踪 main；fuzzy 用 `build()` + `implementation = "rust"`。  
**Consequences**: V2 仍在 active development，后续可能再 break；可用 git 回滚配置 + 恢复 `version = "1.*"`。

## Out of Scope

* 不重构补全 UI
* 不换补全插件
* 不改 blink.pairs
* 不引入 community sources

## Technical Notes

* Install: https://main.cmp.saghen.dev/installation.html
* UPGRADE: https://github.com/saghen/blink.cmp/blob/main/UPGRADE.md
* 环境：Nvim 0.12.4，rustc/cargo 1.87
* 相关文件：`lua/plugins/blink.lua`，`lua/plugins/fluttertools.lua`（只读核对）
