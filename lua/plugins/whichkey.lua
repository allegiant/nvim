local present, key = pcall(require, "which-key")

if not present then
   return
end

local M = {}

local default = {}

M.setup = function()
   key.setup(default)
end

return M
