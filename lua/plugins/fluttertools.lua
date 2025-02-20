return {
  {
    'akinsho/flutter-tools.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'stevearc/dressing.nvim', -- optional for vim.ui.select
    },
    opts = {
      lsp = {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      },
      dev_log = {
        enabled = true,
        open_cmd = "10split", -- command to use to open the log buffer
        focus_on_open = false,
      },
      debugger = { -- integrate with nvim dap + install dart code debugger
        enabled = true,
      },
    }
  },
}
