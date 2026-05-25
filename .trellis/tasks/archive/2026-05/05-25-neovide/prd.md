# 修复 Neovide 字体配置

## Goal

修复 Neovide 启动时字体加载失败的问题，避免默认 fallback 中的泛型 `monospace` 在 Windows 上无法被加载。

## Requirements

* 修改 `C:\Users\alleg\.config\neovide\config.toml`。
* 显式指定已安装的 `JetBrainsMono NFM` 字体。
* 保持修复范围为 Neovide 外部配置，不改 Neovim 仓库运行逻辑。

## Acceptance Criteria

* [ ] `config.toml` 使用合法 TOML 语法。
* [ ] Neovide 字体配置不再依赖泛型 `monospace` fallback。
* [ ] 字体 family 使用当前 Windows 用户字体注册表中存在的名称。

## Definition of Done

* 配置文件已更新。
* TOML 语法已校验。
* 不提交敏感文件，不引入仓库代码行为变更。

## Technical Approach

使用 Neovide 官方 TOML `[font]` 配置格式，设置 `normal` 字体数组为 `JetBrainsMono NFM`，并保留 `hinting` / `edging`。

## Decision (ADR-lite)

**Context**: Neovide 启动时默认 fallback 尝试加载 `monospace`，Windows 环境下该泛型 family 不可靠。
**Decision**: 在 Neovide TOML 中显式指定已安装字体 `JetBrainsMono NFM`，不依赖泛型 fallback。
**Consequences**: 配置更稳定，但依赖该用户字体继续存在；若以后卸载字体，需要更新 family。

## Out of Scope

* 不修改 Neovim `guifont` 配置。
* 不安装或卸载字体。
* 不调整主题、窗口、动画等无关 Neovide 设置。

## Technical Notes

* 已检查 `lua/config/neovide.lua`，仓库内 `guifont` 当前为 `JetBrainsMono Nerd Font Mono:h12`。
* 已检查用户级 Neovide 配置：`C:\Users\alleg\.config\neovide\config.toml` 当前仅含 `[font] size = 2`。
* 已检查 Windows 用户字体注册表，存在 `JetBrainsMono NFM Regular/Bold/Italic/Bold Italic`。
