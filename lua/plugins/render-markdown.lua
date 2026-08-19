return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", desc = "Render Markdown" },
  },
  opts = {
    heading = {
      sign = true,
      icons = { "➊ ", "➋ ", "➌ ", "➍ ", "➎ ", "➏ " },
    },
    code = {
      sign = false,
      width = "block",
      right_pad = 4,
    },
    checkbox = {
      enabled = true,
      unchecked = { icon = "☐ " },
      checked = { icon = "☑ " },
    },
    bullet = {
      enabled = true,
      icons = { "•", "○", "✦", "→" },
    },
  },
}
