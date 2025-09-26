return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    -- "arkav/lualine-lsp-progress",
  },
  opts = {
    options = {
      theme = "gruvbox-material",
    },
    sections = {
      lualine_x = {
        {
          require("lazy.status").updates,
          cond = require("lazy.status").has_updates,
          color = { fg = "#ff9e64" },
        },
      },
      lualine_y = {
        "progress",
        -- "lsp_progress",
      },
    }
  }
}
