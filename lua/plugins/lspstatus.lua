local present, lspStatus = pcall(require, "lsp-status")

if not present then
  return
end

local M = {}

local default = {}

M.setup = function()
  lspStatus.config(default)
end

return M
