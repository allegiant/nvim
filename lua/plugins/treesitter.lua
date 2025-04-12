local utils = require "core.utils"

if utils.is_win() then
  require 'nvim-treesitter.install'.prefer_git = false
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
    "markdown_inline",
    "vue",
    "rust",
  },
  indent = {
    enable = true,
    -- disable = { "dart" },
    -- enable = false,
  },
  highlight = {
    enable = true,
  },
  autotag = {
    enable = true,
  },
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    config = function()
      require("nvim-treesitter.configs").setup(default)
    end,
  },
}
