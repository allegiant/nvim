local present, autotag = pcall(require, "nvim-ts-autotag")
local vim_lsp = vim.lsp

if not present then
   return
end

local M = {}

local default = {}

M.setup = function()
   autotag.setup(default)
end

return M
