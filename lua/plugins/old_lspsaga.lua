local present, lspsaga = pcall(require, "lspsaga")

if not present then
  return
end


local M = {}


M.setup = function()
  lspsaga.setup()
end

return M
