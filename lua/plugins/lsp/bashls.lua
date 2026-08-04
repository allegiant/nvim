local lsp_utils = require("plugins.lsp.utils")

-- cmd/filetypes/root_markers/settings 均使用 lspconfig 内置默认值 (lsp/bashls.lua)

local M = {}

M.setup = function()
  if not lsp_utils.is_mason_package_installed("bash-language-server") then
    return
  end

  vim.lsp.enable('bashls')
end

return M
