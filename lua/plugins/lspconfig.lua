local lsp_installer = require("nvim-lsp-installer")
local lspconfig = require("lspconfig")
local vim_lsp = vim.lsp
local vim_api = vim.api
local vim_tbl_extend = vim.tbl_extend
local vim_uri_to_bufnr = vim.uri_to_bufnr
local vim_notify_once = vim.notify_once
local vim_log = vim.log

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = false,
})

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end





-- fix buffer xxx newer than edits
vim_lsp.util.apply_text_document_edit = function(text_document_edit, _, offset_encoding)
  local text_document = text_document_edit.textDocument
  local bufnr = vim_uri_to_bufnr(text_document.uri)
  if offset_encoding == nil then
    vim_notify_once('apply_text_document_edit must be called with valid offset encoding', vim_log.levels.WARN)
  end

  vim_lsp.util.apply_text_edits(text_document_edit.edits, bufnr, offset_encoding)
end


local on_attach = function(_, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim_api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  require("core.mappings").lspconfig(bufnr)
end

local capabilities = vim_lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)
capabilities.textDocument.completion.completionItem.snippetSupport = true -- cancel comment completion

local M = {}

M.setup = function()
  -- 1. Set up nvim-lsp-installer first!
  lsp_installer.setup {}
  -- 2. (optional) Override the default configuration to be applied to all servers.
  lspconfig.util.default_config = vim_tbl_extend(
    "force",
    lspconfig.util.default_config,
    {
      on_attach = on_attach
    }
  )
  -- 3. Loop through all of the installed servers and set it up via lspconfig
  for _, server in ipairs(lsp_installer.get_installed_servers()) do
    if server.name == "volar" then
      local volar = require("plugins.volar")
      volar.multi_setup(lspconfig, capabilities)
    else
      lspconfig[server.name].setup {
        capabilities = capabilities,
      }
    end

  end
end

return M
