local present, lualine = pcall(require, "lualine")

if not present then
  return
end

local M = {}

local default = {
  options = {
    theme = "gruvbox",
  },
  sections = {
    lualine_x = {
      {
        require("lazy.status").updates,
        cond = require("lazy.status").has_updates,
        color = { fg = "#ff9e64" },
      },
    },
    lualine_y = {
      "lsp_progress",
    },
  },
}

M.setup = function()
  lualine.setup(default)
end

return M
