opts = {
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    relativenumber = true,
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
  },
  filesystem_watchers = {
    enable = false,
  },
}
return {
  -- enabled = false,
  "nvim-tree/nvim-tree.lua",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },

  config = function()
    require("nvim-tree").setup(opts)
    require("core.mappings").nvimtree()
  end,
}
