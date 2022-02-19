local present, telescope = pcall(require, "telescope")

if not present then
  return
end

local M = {}

local default = {
  defaults = {
    mappings = {
      require("core.mappings").telescope(),
    },
  },
}

M.setup = function()
  telescope.setup(default)
end

return M
