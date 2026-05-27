# 修正跨平台 DAP 配置

## Goal

修正 `lua/plugins/dap.lua` 中影响 DAP 可用性的配置，让 Python 调试和 CodeLLDB 在 Windows 与 Linux 环境下都更可靠，同时保持现有快捷键体验，尤其不改动 `<leader>d` 的 group 声明。

## What I already know

* 用户已确认可以处理 `dap-python`、`codelldb` 路径和必要的 C/C++/Rust debug configurations。
* 用户明确要求 `<leader>d` 不用改。
* 用户补充要求同时考虑 Linux 环境。
* `nvim-dap-ui` 的 listener 写法与官方 README 推荐一致。
* `nvim-dap-virtual-text` 的空参数 `setup()` 是基础推荐用法。
* 当前 `dap_python.setup('python')` 依赖系统 `python` 能导入 `debugpy`，但本机 `python` 当前没有 `debugpy`。
* 当前 Windows Mason 安装存在 `codelldb.exe`，现有配置引用无扩展名 `codelldb`，在 Windows 下有风险。
* 当前仓库只看到 `dap.adapters.codelldb`，未看到 C/C++/Rust 的 `dap.configurations`。

## Assumptions (temporary)

* 该配置应继续使用 lazy.nvim 插件 spec 风格。
* 目标是增强默认可用性，不引入新的 DAP 管理插件，除非现有项目已经使用。
* Python 调试应优先使用项目虚拟环境或 Mason/debugpy 可用路径，避免强依赖全局 Python。

## Open Questions

* 无。

## Requirements (evolving)

* 保留 `<leader>d` group 声明不改。
* 保持现有 DAP UI 自动打开/关闭行为。
* 修正 CodeLLDB adapter 路径，使 Windows 和 Linux 都能工作。
* Python DAP 配置优先使用 Mason 提供的 `debugpy-adapter`，缺失时回退到可用的 `python3`/`python`。
* C/C++/Rust CodeLLDB launch 配置使用简单、通用、可维护的基础配置。

## Acceptance Criteria (evolving)

* [ ] `lua/plugins/dap.lua` 在 Windows 下能解析到可执行的 CodeLLDB adapter。
* [ ] `lua/plugins/dap.lua` 在 Linux 下能解析到可执行的 CodeLLDB adapter。
* [ ] Python 调试配置有明确、可靠的 `debugpy` 使用路径或检测策略。
* [ ] C/C++/Rust 若使用 CodeLLDB，有可直接启动的基础 launch configuration。
* [ ] `<leader>d` group 项保持不变。
* [ ] 配置加载不报错。

## Definition of Done (team quality bar)

* 配置变更完成后运行可行的 Neovim headless 加载检查。
* 不引入重复配置或无必要的新依赖。
* 不提交敏感文件或环境特定绝对路径。
* 如发现可沉淀的跨平台配置约定，再考虑更新 spec。

## Out of Scope (explicit)

* 不修改 `<leader>d` group 声明。
* 不重构整个 DAP 插件结构。
* 不引入新的 UI 或快捷键设计。
* 不处理具体语言项目的复杂 launch.json 模板。

## Technical Notes

* 目标文件：`lua/plugins/dap.lua`
* 已检查文档：`mfussenegger/nvim-dap`、`rcarriga/nvim-dap-ui`、`mfussenegger/nvim-dap-python`、`theHamsta/nvim-dap-virtual-text`。
* 已确认 Windows Mason CodeLLDB 路径：`C:\Users\alleg\AppData\Local\nvim-data\mason\packages\codelldb\extension\adapter\codelldb.exe`。
* 当前系统 Python 检查结果：`ModuleNotFoundError: No module named 'debugpy'`。

## Research References

* [`research/dap-cross-platform.md`](research/dap-cross-platform.md) — 推荐用 Mason registry 显式定位 CodeLLDB，配合 `${port}` 动态端口；Python 优先 `debugpy-adapter`。

## Decision (ADR-lite)

**Context**: 当前 DAP 配置假设全局 `python` 有 `debugpy`，且 CodeLLDB 路径偏 Linux/macOS，在 Windows 下缺少 `.exe`，同时固定端口存在冲突风险。

**Decision**: Python 调试优先使用 Mason `debugpy-adapter`，缺失时回退 `python3`/`python`；CodeLLDB 使用 Mason registry 获取安装路径并按平台拼接 adapter 可执行文件；CodeLLDB 使用 `${port}` 动态端口；补充基础 C/C++/Rust launch 配置。

**Consequences**: 不新增 `mason-nvim-dap.nvim` 依赖，改动集中在 `lua/plugins/dap.lua`；如果 Mason 未安装 `debugpy` 或 `codelldb`，配置应优雅回退或跳过对应 adapter，而不是启动时报错。
