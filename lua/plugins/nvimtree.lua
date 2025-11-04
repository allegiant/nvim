return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "NvimTree Toggle" },
  },
  opts = {
    sort = {
      sorter = "case_sensitive",
    },
    view = {
      relativenumber = true,
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
      enable = true,
      ignore_dirs = {
        "/.ccls-cache",
        "/build",
        "/node_modules",
        "/target",
      },
    },
    diagnostics = {
      enable = false,
      icons = {
        hint = "",
        info = "",
        warning = "",
        error = "",
      },
    },
  },
}
