local lsp_utils = require("plugins.lsp.utils")

local vue_language_server_path = vim.fn.expand "$MASON/packages/vue-language-server" ..
    "/node_modules/@vue/language-server"

local vue_plugin               = {
  name = '@vue/typescript-plugin',
  location = vue_language_server_path,
  languages = { 'vue' },
  configNamespace = 'typescript',
}
local vtsls_config             = {
  settings = {
    vtsls = {
      tsserver = {
        globalPlugins = {
          vue_plugin,
        },
      },
    },
  },
  filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
}

local M                        = {}

M.setup                        = function()
  if not lsp_utils.is_mason_package_installed("vue-language-server") then
    return
  end

  if not lsp_utils.is_mason_package_installed("vtsls") then
    return
  end

  vim.lsp.config('vtsls', vtsls_config)
  vim.lsp.config('vue_ls', {})
  vim.lsp.enable({ 'vtsls', 'vue_ls' })
end

return M
