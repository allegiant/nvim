local present, autopairs = pcall(require, "nvim-autopairs")

if not present then
  return
end





local M = {}

local default = {}

M.setup =  function ()
  autopairs.setup(default)
end
return M
