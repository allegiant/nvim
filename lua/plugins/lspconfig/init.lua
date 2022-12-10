local mason = require("mason");
local mason_lspconfig = require("mason-lspconfig");
local lspconfig = require("lspconfig")
local vim_tbl_extend = vim.tbl_extend
local api = vim.api

local capabilities = require("cmp_nvim_lsp").default_capabilities()

local signs = {
  Error = " ",
  Warn = " ",
  Hint = " ",
  Info = " "
}

for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.diagnostic.config({
  signs = true,
  update_in_insert = false,
  underline = true,
  severity_sort = true,
  virtual_text = {
    source = true,
  },
})



local on_attach = function(client, bufnr)
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



local M = {}

M.on_attach = on_attach

M.setup = function()
  mason.setup();
  mason_lspconfig.setup();

  lspconfig.util.default_config = vim_tbl_extend(
    "force",
    lspconfig.util.default_config,
    {
      on_attach = on_attach
    }
  )
  -- 3. Loop through all of the installed servers and set it up via lspconfig
  for _, server_name in ipairs(mason_lspconfig.get_installed_servers()) do
    if server_name == "volar" then
      require("plugins.lspconfig.volar").setup(lspconfig, capabilities)
    elseif server_name == "sumneko_lua" then
      lspconfig[server_name].setup(require("plugins.lspconfig.sumneko_lua"))
    elseif server_name == "rust_analyzer" then
      -- lspconfig[server_name].setup(require("plugins.lspconfig.rust"))
    else
      lspconfig[server_name].setup {
        capabilities = capabilities,
      }
    end

  end
end

return M
