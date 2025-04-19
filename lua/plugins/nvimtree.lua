return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons", },
  keys = {
    { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "NvimTree Toggle" },
  },
  config = function()
    require("nvim-tree").setup({
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
      }
    })
  end,
}
