local present, gitsigns = pcall(require, "gitsigns")

if not present then
   return
end

local M = {}

M.setup = function()
   gitsigns.setup {
      on_attach = function(bufnr)
         require("core.mappings").gitsigns(bufnr)
      end,
   }
end

return M
