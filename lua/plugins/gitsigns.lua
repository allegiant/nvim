return {
  "lewis6991/gitsigns.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local gitsigns = require("gitsigns")
    gitsigns.setup({
      on_attach = function(bufnr)
        require("core.mappings").gitsigns(bufnr, gitsigns)
      end,
    })
  end,
}
