local lsp_utils = require("plugins.lsp.utils")

-- cmd/filetypes 使用 lspconfig 内置默认值 (lsp/sqls.lua)
local opts = {
  root_markers = { "config.yml", ".sqlsrc.yml" }
}

local M = {}

M.setup = function()
  if not lsp_utils.is_mason_package_installed("sqls") then
    return
  end

  vim.lsp.config('sqls', opts)
  vim.lsp.enable('sqls')
end

return M
