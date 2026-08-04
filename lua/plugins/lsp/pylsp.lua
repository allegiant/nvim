local lsp_utils = require("plugins.lsp.utils")

-- cmd/filetypes/root_markers 均使用 lspconfig 内置默认值 (lsp/pylsp.lua)
local opts = {
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = {
          ignore = { 'W391' },
          maxLineLength = 100
        }
      }
    }
  }
}

local M = {}

M.setup = function()
  if not lsp_utils.ensure_executable({
    cmd = "pylsp",
    filetypes = "python",
    install = ":MasonInstall python-lsp-server",
  }) then
    return
  end

  vim.lsp.config('pylsp', opts)
  vim.lsp.enable('pylsp')
end

return M
