local mason = require("mason");
local mason_lspconfig = require("mason-lspconfig");
local lspconfig = require("lspconfig")
local lspconfig_common = require("plugins.lspconfig.common")
local vim_tbl_extend = vim.tbl_extend
-- local capabilities = require("cmp_nvim_lsp").default_capabilities()
local capabilities = lspconfig_common.capabilities()

local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or "single"
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

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


local on_attach = lspconfig_common.on_attach

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
    elseif server_name == "lua_ls" then
      lspconfig[server_name].setup(require("plugins.lspconfig.lua_ls"))
    elseif server_name == "rust_analyzer" then
    elseif server_name == "yamlls" then
      lspconfig[server_name].setup(require("plugins.lspconfig.yamlls"))
    else
      lspconfig[server_name].setup {
        capabilities = capabilities,
      }
    end
  end
end

return M
