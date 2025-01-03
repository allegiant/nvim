local lspconfig_common = require("plugins.lspconfig.common")
local ok, ft = pcall(require, "flutter-tools")
if not ok then
  return
end

local M = {}

local opts = {
  lsp = {
    on_attach = lspconfig_common.on_attach,
    capabilities = lspconfig_common.capabilities(),
  }

}

M.setup = function()
  ft.setup(opts)
end

return M
