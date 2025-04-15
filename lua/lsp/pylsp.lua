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
}

local M = {}

M.setup = function()
  local present, mason_registry = pcall(require, "mason-registry")
  if not present then
    return
  end

  local installed = mason_registry.is_installed("python-lsp-server")
  if not installed then
    return
  end


  vim.lsp.config('pylsp', opts)
  vim.lsp.enable('pylsp')
end

return M
