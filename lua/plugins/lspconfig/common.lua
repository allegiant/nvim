local api = vim.api

local M = {}

M.on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  require("core.mappings").lspconfig(bufnr)

  if client.server_capabilities.documentFormattingProvider then
    api.nvim_create_autocmd('BufWritePre', {
      pattern = client.config.filetypes,
      callback = function()
        vim.lsp.buf.format({
          bufnr = bufnr,
          async = true,
        })
      end,
    })
  end
end

M.capabilities = function()
  local present, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if not present then
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    return capabilities
  else
    local capabilities = cmp_nvim_lsp.default_capabilities()
    return capabilities
  end
end

return M
