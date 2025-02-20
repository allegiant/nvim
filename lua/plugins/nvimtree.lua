local default = {
  sort_by = "case_sensitive",
  view = {
    adaptive_size = true,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = false,
  },
  git = {
    enable = false,
    ignore = false,
  },
}

return {
  "nvim-tree/nvim-tree.lua",
  event = "vimEnter",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-tree").setup(default)
    require("core.mappings").nvimtree()
  end,
}
