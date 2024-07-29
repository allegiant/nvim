local lspconfig_common = require("plugins.lspconfig.common")
local ok, _ra = pcall(require, "rustaceanvim")
if not ok then
  return
end

local M = {}

M.config = function()
  return {
    server = {
      on_attach = lspconfig_common.on_attach,
      capabilities = lspconfig_common.capabilities(),
    }
  }
end
return M
