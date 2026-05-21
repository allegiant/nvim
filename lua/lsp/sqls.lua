local lsp_utils = require("lsp.utils")

local opts = {
  cmd = { "sqls" },
  filetypes = { "sql", "mysql" },
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
