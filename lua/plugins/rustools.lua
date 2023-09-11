local lspconfig_common = require("plugins.lspconfig.common")
local ok, rt = pcall(require, "rust-tools")
if not ok then
  return
end

local M = {}

local opts = {
  tools = {
    reload_workspace_from_cargo_toml = true,
  },
  server = {
    cmd = {"ra-multiplex","client" },
    on_attach = lspconfig_common.on_attach,
    capabilities = lspconfig_common.capabilities(),
  },
}

M.setup = function()
  require("rust-tools").setup(opts)
end

return M
