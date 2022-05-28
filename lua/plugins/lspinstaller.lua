local lsp_installer = require "nvim-lsp-installer"
local vim_api = vim.api
local vim_lsp = vim.lsp

local capabilities = vim_lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)

capabilities.textDocument.completion.completionItem.snippetSupport = true

-- do something on lsp on_attach
local function on_attach(client, bufnr)
  client.resolved_capabilities.document_formatting = false
  client.resolved_capabilities.document_range_formatting = false

  -- set mappings only in current buffer with lsp enabled
  local function buf_set_keymap(...)
    vim_api.nvim_buf_set_keymap(bufnr, ...)
  end

  -- set options only in current buffer with lsp enabled
  local function buf_set_option(...)
    vim_api.nvim_buf_set_option(bufnr, ...)
  end

  buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
  require("core.mappings").lsp(buf_set_keymap)
end

local installed_servers = lsp_installer.get_installed_servers()

local opts = {
  on_attach = on_attach,
  capabilities = capabilities,
}

for _, server in pairs(installed_servers) do
  if server.name == "volar" then
    require("plugins.volar").setup(opts)
  else
    server:setup(opts)
  end
end
