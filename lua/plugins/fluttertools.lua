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
  },
  dev_log = {
    enabled = true,
    open_cmd = "10split", -- command to use to open the log buffer
  },
  debugger = { -- integrate with nvim dap + install dart code debugger
    enabled = true,
  },

}

M.setup = function()
  ft.setup(opts)
end

return M
