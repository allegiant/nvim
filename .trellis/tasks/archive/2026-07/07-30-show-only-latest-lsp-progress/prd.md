# Show only latest LSP progress

## Goal
LSP progress 通知只显示最新一条，避免多 token 叠成「两条 lua_ls」。

## Requirements
- 修改 `lua/plugins/snacks/lsp_progress.lua`
- 通知内容仅保留当前最新 progress 消息
- 保留 spinner / done 图标行为

## Acceptance Criteria
- [x] 同一 client 多 token 时 notify 只含最新 msg
