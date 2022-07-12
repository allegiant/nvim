local present, ts_config = pcall(require, "nvim-treesitter.configs")

if not present then
  return
end

local default = {
  ensure_installed = {
    "lua",
    "vim",
    "html",
    "css",
    "javascript",
    "typescript",
    "json",
    "markdown",
    "vue",
  },
  indent = {
    enable = true,
    disable = { "vue" }
  },
  highlight = {
    enable = true,
  },
  context_commentstring = {
    enable = true
  },
  autotag = {
    enable = true,
  },
}

local M = {}

M.setup = function()
  ts_config.setup(default)
end

return M
