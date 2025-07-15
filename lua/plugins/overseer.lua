return {
  'stevearc/overseer.nvim',
  keys = {
    { "<leader>r",  group = "Run Tasks" },
    { "<leader>rr", "<cmd>OverseerRun<CR>",    desc = "run" },
    { "<leader>rt", "<cmd>OverseerToggle<CR>", desc = "toggle tasks" },
    { "<leader>ro", "<cmd>OverseerOpen<CR>",   desc = "Open tasks" },
    { "<leader>rc", "<cmd>OverseerClose<CR>",  desc = "Close tasks" },
  },
  opts = {
    strategy = {
      "toggleterm",
      direction = 'vertical',
    },
    templates = { "builtin", "user.lua_run" }
  },

}
