# Journal - xu (Part 1)

> AI development session journal
> Started: 2026-05-12

---



## Session 1: 初始化 Trellis 规范并整理忽略规则

**Date**: 2026-05-13
**Task**: 初始化 Trellis 规范并整理忽略规则
**Branch**: `master`

### Summary

填充 Trellis backend/frontend 项目规范；将 Trellis workspace 会话日志标记为本地忽略；提交 Claude/Trellis 工作流基础设施。

### Main Changes

(Add details)

### Git Commits

| Hash | Message |
|------|---------|
| `06ffc9d` | (see git log) |
| `7eaa3b5` | (see git log) |
| `8a3108c` | (see git log) |

### Testing

- [OK] (Add test results)

### Status

[OK] **Completed**

### Next Steps

- None - task complete


## Session 2: 修复 Claude Code 终端 Esc 行为

**Date**: 2026-05-13
**Task**: 修复 Claude Code 终端 Esc 行为
**Branch**: `master`

### Summary

将 ToggleTerm 终端键位限定到 ToggleTerm buffer；为 coder/claudecode.nvim 的 active terminal 添加 buffer-local Esc 映射，避免 Esc 传给 Claude 导致退出或中断。

### Main Changes

(Add details)

### Git Commits

| Hash | Message |
|------|---------|
| `0374f6a` | (see git log) |

### Testing

- [OK] (Add test results)

### Status

[OK] **Completed**

### Next Steps

- None - task complete


## Session 3: Neovim LSP 与格式化配置优化

**Date**: 2026-05-21
**Task**: Neovim LSP 与格式化配置优化
**Branch**: `master`

### Summary

精简 blink.cmp 配置，更新 diagnostic 跳转 API，修复 sqls cwd 绑定，抽取 Mason 包检查 helper，优化 lua_ls 与 conform.nvim 配置。

### Main Changes

(Add details)

### Git Commits

| Hash | Message |
|------|---------|
| `7b62684` | (see git log) |
| `462ccff` | (see git log) |
| `1b73f42` | (see git log) |
| `d3eea19` | (see git log) |
| `5b445fe` | (see git log) |
| `84e2444` | (see git log) |

### Testing

- [OK] (Add test results)

### Status

[OK] **Completed**

### Next Steps

- None - task complete


## Session 4: 修复 Neovide 字体配置

**Date**: 2026-05-25
**Task**: 修复 Neovide 字体配置
**Branch**: `master`

### Summary

更新用户级 Neovide config.toml，显式使用已安装的 JetBrainsMono NFM 字体，并通过 tomllib 校验 TOML 语法。

### Main Changes

(Add details)

### Git Commits

(No commits - planning session)

### Testing

- [OK] (Add test results)

### Status

[OK] **Completed**

### Next Steps

- None - task complete


## Session 5: 修复 Neovide 字体启动报错

**Date**: 2026-05-25
**Task**: 修复 Neovide 字体启动报错
**Branch**: `master`

### Summary

修正 Neovide 专用 guifont 为 Windows 实际注册的 JetBrainsMono NFM，并记录 Neovide 默认 guifont 早期触发 monospace 报错的排查结论。

### Main Changes

(Add details)

### Git Commits

| Hash | Message |
|------|---------|
| `0b3b5af` | (see git log) |

### Testing

- [OK] (Add test results)

### Status

[OK] **Completed**

### Next Steps

- None - task complete


## Session 6: Fix cross-platform DAP config

**Date**: 2026-05-27
**Task**: Fix cross-platform DAP config
**Branch**: `master`

### Summary

Updated nvim-dap configuration to resolve Python debugpy and CodeLLDB adapters safely across Windows and Linux, added dynamic CodeLLDB ports and baseline C/C++/Rust launch configs, and verified headless Neovim loading.

### Main Changes

- Resolved Python DAP setup through Mason `debugpy-adapter` when available, with guarded fallback to `python3`/`python` only when `debugpy` imports successfully.
- Resolved CodeLLDB through guarded Mason package lookup with Windows/Linux adapter names and `${port}` dynamic port allocation.
- Added baseline C/C++/Rust CodeLLDB launch configurations while preserving the existing `<leader>d` group mapping.

### Git Commits

| Hash | Message |
|------|---------|
| `62708c0` | fix: make DAP adapters cross-platform |

### Testing

- [OK] `nvim --headless "+luafile init.lua" "+qa"`
- [OK] Forced `nvim-dap` lazy load and inspected DAP adapters/configurations.

### Status

[OK] **Completed**

### Next Steps

- None - task complete
