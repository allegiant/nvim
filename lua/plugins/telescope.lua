return {
  {
    "nvim-telescope/telescope.nvim",
    branch = '0.1.x',
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>f",  group = "File" },
      { "<leader>ff", "<cmd>Telescope find_files<cr>",  desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",   desc = "Find live_grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",     desc = "Find Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>",   desc = "Find help_tags" },
      { "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = "Find grep_tring" },
      { "<leader>fr", "<cmd>Telescope resume<cr>",      desc = "Find search history" },
    },
    config = function()
      require("telescope").setup()
    end,
  }
}
