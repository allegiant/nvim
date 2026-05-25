# 修正 Neovide 实际配置路径

## Goal

修复 Neovide 仍然使用默认字体 fallback 的问题，把字体配置写到 Windows 版 Neovide 默认读取的配置路径，避免 `monospace` fallback 加载失败。

## Requirements

* 在 `C:\Users\alleg\AppData\Roaming\neovide\config.toml` 创建 Neovide 配置。
* 配置显式使用当前用户已安装的 `JetBrainsMono NFM` 字体。
* 保留 `C:\Users\alleg\.config\neovide\config.toml` 不动，避免破坏用户提供路径中的配置。
* 仓库 Neovide 专用配置中的 `guifont` 使用真实已安装字体 `JetBrainsMono NFM:h12`。
* 仅修改 Neovide 专用仓库配置，不改普通 Neovim 启动逻辑。

## Acceptance Criteria

* [ ] Roaming 路径下存在 `config.toml`。
* [ ] TOML 语法可被 Python `tomllib` 解析。
* [ ] 配置不依赖默认 `monospace` fallback。
* [ ] 配置字号不再显示为 Neovide 默认的 `18.666668`。
* [ ] `nvim --headless --cmd "let g:neovide=1" +"set guifont?" +qa` 报告 `guifont=JetBrainsMono NFM:h12`。

## Definition of Done

* 实际读取路径配置已写入。
* TOML 语法已校验。
* 不安装字体，不改无关 Neovide 设置。

## Technical Approach

Windows 版 Neovide 默认配置文件位置是 `%APPDATA%\neovide\config.toml`；当前 `NEOVIDE_CONFIG` 为空，且该路径不存在，所以 `.config\neovide\config.toml` 未生效。创建 Roaming 路径配置，并写入同样的 `[font]` 设置。

## Decision (ADR-lite)

**Context**: 截图仍显示默认 fallback 列表 `Cascadia Code/Cascadia Mono/Consolas/Courier New/monospace` 和默认字号 `18.666668`，说明上一处 `.config` 配置没有被读取。
**Decision**: 写入 Windows 默认读取路径 `%APPDATA%\neovide\config.toml`。
**Consequences**: Neovide 启动时应直接读取该文件；`.config` 文件仍保留但不是当前生效路径。

## Out of Scope

* 不设置系统级 `NEOVIDE_CONFIG` 环境变量。
* 不删除 `.config\neovide\config.toml`。
* 不修改普通 Neovim 会话的 `guifont`；只修正 `vim.g.neovide` 分支下的 Neovide 专用设置。

## Technical Notes

* `NEOVIDE_CONFIG` 当前为空。
* `C:\Users\alleg\AppData\Roaming\neovide` 当前不存在。
* `C:\Users\alleg\.config\neovide\config.toml` 已含 `JetBrainsMono NFM`，但截图证明未生效。
* Windows 字体检查确认真实已安装字体族名是 `JetBrainsMono NFM`。
* 仓库 Neovide 专用配置原先设置 `JetBrainsMono Nerd Font Mono:h12`，`nvim --headless --cmd "let g:neovide=1" +"set guifont?" +qa` 会报告该未安装族名，需要修正为 `JetBrainsMono NFM:h12`。
