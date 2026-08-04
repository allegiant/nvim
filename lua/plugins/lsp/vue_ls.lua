local lsp_utils = require("plugins.lsp.utils")

-- Vue 3 hybrid 模式的官方配方：vue_ls 管 HTML/CSS，
-- .vue 中的 TypeScript 由 vtsls + @vue/typescript-plugin 提供
-- (参见 nvim-lspconfig vtsls 文档 "Vue support" 一节)
local vue_language_server_path = vim.fn.expand('$MASON/packages/vue-language-server')
  .. '/node_modules/@vue/language-server'

local vue_plugin = {
  name = '@vue/typescript-plugin',
  location = vue_language_server_path,
  languages = { 'vue' },
  configNamespace = 'typescript',
}

local vtsls_config = {
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

local M = {}

M.setup = function()
  if not lsp_utils.ensure_executable({
    cmd = "vue-language-server",
    filetypes = "vue",
    install = ":MasonInstall vue-language-server",
  }) then
    return
  end

  if not lsp_utils.ensure_executable({
    cmd = "vtsls",
    filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
    install = ":MasonInstall vtsls",
  }) then
    return
  end

  vim.lsp.config('vtsls', vtsls_config)
  vim.lsp.enable({ 'vtsls', 'vue_ls' })
end

return M
