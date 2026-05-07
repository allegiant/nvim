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
      debounce_delay = 50, -- 增加一点防抖延迟
      ignore_dirs = {
        ".ccls-cache",
        "build",
        "node_modules",
        "target",
        ".git",
        ".idea",
        ".gradle"
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
