local lsp_utils = require("plugins.lsp.utils")

-- cmd/filetypes/root_markers/settings 均使用 lspconfig 内置默认值 (lsp/bashls.lua)

local M = {}

M.setup = function()
  if not lsp_utils.ensure_executable({
    cmd = "bash-language-server",
    filetypes = { "sh", "bash" },
    install = ":MasonInstall bash-language-server",
  }) then
    return
  end

  vim.lsp.enable('bashls')
end

return M
