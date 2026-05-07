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
  local present, mason_registry = pcall(require, "mason-registry")
  if not present then
    return
  end

  local installed = mason_registry.is_installed("vue-language-server")
  if not installed then
    return
  end
  vim.lsp.config('vtsls', vtsls_config)
  vim.lsp.config('vue_ls', {})
  vim.lsp.enable({ 'vtsls', 'vue_ls' })
end

return M
