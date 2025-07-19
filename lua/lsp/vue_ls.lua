local opts = {
  filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
  init_options = {
    vue = {
      hybridMode = false,
    },
  },
  settings = {
    typescript = {
      inlayHints = {
        enumMemberValues = {
          enabled = true,
        },
        functionLikeReturnTypes = {
          enabled = true,
        },
        propertyDeclarationTypes = {
          enabled = true,
        },
        parameterTypes = {
          enabled = true,
          suppressWhenArgumentMatchesName = true,
        },
        variableTypes = {
          enabled = true,
        },
      },
    },
  },
}


local M = {}

M.setup = function()
  local present, mason_registry = pcall(require, "mason-registry")
  if not present then
    return
  end

  local installed = mason_registry.is_installed("vue-language-server")
  if not installed then
    return
  end

  vim.lsp.config["ts_ls"] = {}
  vim.lsp.config('vue_ls', opts)
  vim.lsp.enable('vue_ls')
end

return M
