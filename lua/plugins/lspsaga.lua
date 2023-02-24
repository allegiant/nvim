local present, lspsaga = pcall(require, "lspsaga")

if not present then
  return
end


local M = {}

local default = {
}


M.setup = function()
  lspsaga.setup(default)
end

return M
