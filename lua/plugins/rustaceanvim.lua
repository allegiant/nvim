return {
  "mrcjkb/rustaceanvim",
  version = "^5", -- Recommended
  config = function()
    vim.g.rustaceanvim = {
      server = {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
        default_settings = {
          -- rust-analyzer language server configuration
          ["rust-analyzer"] = {
            diagnostics = {
              enable = true,
            },
            checkOnSave = false,
            files = {
              watcher = "client",
            },
          },
        },
      },

      -- dap = {},
    }
  end,
}
