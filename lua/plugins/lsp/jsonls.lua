local lsp_utils = require("plugins.lsp.utils")

--Enable (broadcasting) snippet capability for completion
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local opts = {
  capabilities = capabilities,
  cmd = { 'vscode-json-language-server', '--stdio' },
  filetypes = { 'json', 'jsonc' },
  init_options = {
    provideFormatter = true,
  },
  root_markers = { '.git' },
}

local M = {}

M.setup = function()
  if not lsp_utils.is_mason_package_installed("json-lsp") then
    return
  end

  vim.lsp.config('jsonls', opts)
  vim.lsp.enable('jsonls')
end

return M
