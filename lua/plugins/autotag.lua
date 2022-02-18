local present, autotag = pcall(require, "nvim-ts-autotag")
local vim_lsp = vim.lsp

if not present then
   return
end

vim_lsp.handlers["textDocument/publishDiagnostics"] = vim_lsp.with(vim_lsp.diagnostic.on_publish_diagnostics, {
   underline = true,
   virtual_text = {
      spacing = 5,
      severity_limit = "Warning",
   },
   update_in_insert = true,
})

local M = {}

local default = {}

M.setup = function()
   autotag.setup(default)
end

return M
