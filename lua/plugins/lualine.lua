local present, lualine = pcall(require, "lualine")

if not present then
   return
end

local M = {}

local default = {
   options = {
      theme = "gruvbox",
   },
}

M.setup = function()
   lualine.setup(default)
end

return M
