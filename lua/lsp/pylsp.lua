local lsp_utils = require("lsp.utils")

local opts = {
  cmd = { 'pylsp' },
  filetypes = { 'python' },
  root_markers = {
    'pyproject.toml',
    'setup.py',
    'setup.cfg',
    'requirements.txt',
    'Pipfile',
    '.git',
  },
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
  if not lsp_utils.is_mason_package_installed("python-lsp-server") then
    return
  end

  vim.lsp.config('pylsp', opts)
  vim.lsp.enable('pylsp')
end

return M
