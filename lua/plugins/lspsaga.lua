local present, lspsaga = pcall(require, "lspsaga")

if not present then
  return
end


local M = {}


M.setup = function()
  lspsaga.init_lsp_saga({})
end

return M
