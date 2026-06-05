# 迁移 nvim-treesitter 0.12 配置

## Goal

将当前 Neovim 0.12 配置中的 `nvim-treesitter` 从旧版 option-table 写法迁移到 main 分支新版写法，修复打开 `lua/plugins/themes.lua` 时由 `vim` parser/query 错配触发的 `Invalid node type "tab"` 报错，并通过独立 autotag 插件恢复 HTML/Vue/JSX/TSX 等标签自动补全/重命名能力。

## What I already know

* 用户当前 Neovim 版本是 0.12，适合继续使用 `nvim-treesitter` main 分支，而不是回退到旧 `master` 分支。
* 用户选择本次范围为“迁移 Treesitter + 补独立 autotag 插件”。
* `lazy-lock.json` 中 `nvim-treesitter` 已锁定在 `main` 分支。
* `lua/plugins/treesitter.lua` 当前仍使用旧式配置字段：`ensure_installed`、`highlight.enable`、`indent.enable`、`autotag.enable`。
* 报错点来自 data 目录下 `nvim-treesitter` 的 `runtime/queries/vim/highlights.scm:113`，query 包含 `"tab"`，但当前加载的 `vim` parser 不认识该节点。
* 打开 `lua/plugins/themes.lua` 会触发该错误，是因为其中 `vim.cmd([[colorscheme gruvbox-material]])` 的字符串可能被 Lua Treesitter 注入为 Vimscript 高亮，从而加载 `vim` highlighter。
* 仓库内没有发现本地 `queries/` 或 `parser/` 覆盖文件，错配更可能来自已安装 parser 残留、runtimepath 优先级或 parser 未随插件更新。
* 仓库内当前没有 `windwp/nvim-ts-autotag` 或其他独立 autotag 插件配置。

## Research References

* [`research/nvim-treesitter-0-12-migration.md`](research/nvim-treesitter-0-12-migration.md) — 记录了 main 分支新版 lazy.nvim spec、parser 安装/更新 API、`vim.treesitter.start()`、`indentexpr()` 与 query/parser mismatch 诊断。
* [`research/autotag-plugin.md`](research/autotag-plugin.md) — 记录了恢复旧 autotag 行为所需的 `windwp/nvim-ts-autotag` 当前 API、lazy.nvim 配置、相关 filetypes、parser 依赖和 main 分支迁移陷阱。

## Requirements

* 保持 `nvim-treesitter` 使用 `main` 分支，适配 Neovim 0.12。
* 更新 `lua/plugins/treesitter.lua`，移除旧式 `require("nvim-treesitter").setup(default)` 配置写法。
* 使用新版 `require("nvim-treesitter").install(...)` 管理 parser 安装列表。
* 通过 `FileType` autocmd 调用 `vim.treesitter.start()` 启用 Treesitter 高亮。
* 对 parser 缺失或启动失败做保护，避免单个 parser/query 问题中断打开文件。
* 保留现有 parser 覆盖范围：`lua`、`vim`、`html`、`css`、`javascript`、`typescript`、`json`、`markdown`、`markdown_inline`、`vue`、`rust`。
* 为 autotag 相关场景补充必要 parser：至少包含 JSX/TSX 对应 parser（如 `tsx`），以支持 React 风格标签编辑；如实现 agent 判断 parser 名称与新版 manifest 不匹配，应以 `:TSInstallInfo`/插件 manifest 可用名称为准并说明取舍。
* 保持 `build = ":TSUpdate"`，并补充 `lazy = false`，符合新版文档要求。
* 添加独立 `windwp/nvim-ts-autotag` 插件配置，替代旧 `autotag = { enable = true }`。
* `nvim-ts-autotag` 配置使用当前 standalone API：`require("nvim-ts-autotag").setup(...)`，不再通过 `nvim-treesitter.configs` 集成。
* 迁移后执行可行的 headless 验证，至少验证配置可加载，且打开 `lua/plugins/themes.lua` 不再触发启动期 Lua 错误。

## Acceptance Criteria

* [ ] `lua/plugins/treesitter.lua` 不再调用旧式 `require("nvim-treesitter").setup(default)`。
* [ ] `nvim-treesitter` 插件 spec 包含 `lazy = false` 和 `build = ":TSUpdate"`。
* [ ] parser 列表被复用，不重复硬编码多个不一致列表。
* [ ] FileType autocmd 使用 `pcall(vim.treesitter.start, args.buf)` 或等价保护。
* [ ] 旧 `autotag = { enable = true }` 从 Treesitter 配置中移除。
* [ ] 新增 `windwp/nvim-ts-autotag` lazy.nvim spec，并调用 standalone setup。
* [ ] `nvim-ts-autotag` 依赖/加载顺序不会要求懒加载 `nvim-treesitter` 本体。
* [ ] `lua/plugins/themes.lua` 在 headless 检查中可以打开，不因 Treesitter query/parser 错配导致 Lua 异常退出。
* [ ] 如验证发现本机 parser 残留仍导致错误，给出明确的本地修复命令，不把 data 目录产物提交到仓库。

## Definition of Done

* 完成代码迁移并匹配现有 Lua 风格。
* 不引入 copy-paste parser 列表漂移。
* 清理不再使用的 import/变量。
* 运行验证命令并记录结果。
* 若新增插件导致 lockfile 需要更新，运行合适的 lazy.nvim 同步/安装命令并记录结果。
* 若发现新版迁移相关经验值得保存，再考虑更新 Trellis spec。

## Technical Approach

采用“新版 Treesitter 迁移 + 独立 autotag 插件”方案：

1. 将旧 `default.ensure_installed` 改为单一 `parsers` 列表。
2. 插件配置中设置 `lazy = false`、`build = ":TSUpdate"`。
3. `config` 中调用 `require("nvim-treesitter").install(parsers)`。
4. 创建 `FileType` autocmd，对与 parser 同名的常用 filetype 启用：
   * `pcall(vim.treesitter.start, args.buf)` 保护高亮启动；
   * 设置 `vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"` 以替代旧 `indent.enable`。
5. 对 `markdown_inline` 仅保留 parser 安装，不作为 FileType pattern，因为常见 filetype 是 `markdown`。
6. 为 JSX/TSX/前端标签场景补充 parser/filetype 覆盖，避免 autotag 插件加载后因 parser 缺失无法工作。
7. 移除未使用的 `core.utils` 引入和旧注释，避免迁移后遗留旧 install API。
8. 在同一 `lua/plugins/treesitter.lua` 返回列表里新增 `windwp/nvim-ts-autotag` spec，保持 Treesitter 相关配置聚合：
   * `dependencies = { "nvim-treesitter/nvim-treesitter" }`；
   * 可使用 `event = { "BufReadPre", "BufNewFile" }` 或 `lazy = false`；实现时优先选择与 README 和本仓库启动风格兼容、简单可靠的写法；
   * `config = function() require("nvim-ts-autotag").setup({ opts = { enable_close = true, enable_rename = true, enable_close_on_slash = false } }) end`，除非当前插件 API 文档/本地安装要求不同。

## Decision (ADR-lite)

**Context**: nvim-treesitter main 分支是面向 Neovim 0.12 的不兼容重写，旧式 `setup({ ensure_installed, highlight, indent, autotag })` 已不适合当前分支；报错属于 query/parser revision mismatch。旧 autotag 需求不再适合放在 nvim-treesitter option table 中。

**Decision**: 使用 main 分支新版 API，不回退 `master`；在仓库内迁移 Treesitter 配置，并引入独立 `windwp/nvim-ts-autotag` 恢复旧 autotag 行为；在本地通过 parser 更新/重装解决 data 目录错配。

**Consequences**: 配置更贴近新版文档；高亮启用改由 Neovim 内置 `vim.treesitter.start()` 控制；autotag 功能由独立插件维护；若本机存在旧 parser 残留，仍需执行 `:TSUpdate vim` 或强制重装 parser。

## Out of Scope

* 不切换到 `master` 分支。
* 不提交或修改 `C:\Users\alleg\AppData\Local\nvim-data` 下插件/parser 产物。
* 不全面重构其他插件配置。
* 不为所有 `nvim-ts-autotag` 支持语言一次性安装全部 parser，仅覆盖当前配置已有语言和合理的前端扩展场景。

## Technical Notes

* 主要影响文件：`lua/plugins/treesitter.lua`。
* 可能影响文件：`lazy-lock.json`，如果验证/同步新增 `nvim-ts-autotag` 后 lockfile 更新。
* 参考文件：`lazy-lock.json` 中 `nvim-treesitter` 为 `main` 分支。
* 触发错误相关文件：`lua/plugins/themes.lua` 中的 `vim.cmd([[colorscheme gruvbox-material]])`。
* 可用诊断命令：`:checkhealth nvim-treesitter`、`:TSUpdate vim`、`:TSInstall! vim`、`:echo nvim_get_runtime_file('*/vim.so', v:true)`、`:echo nvim_get_runtime_file('queries/vim/*.scm', v:true)`。
