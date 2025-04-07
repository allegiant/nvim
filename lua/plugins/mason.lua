return {
  "williamboman/mason-lspconfig.nvim",
  dependencies = {
    "williamboman/mason.nvim",
    "neovim/nvim-lspconfig",
  },
  config = function()
    local lspconfig = require("lspconfig")
    require("mason").setup()
    require("mason-lspconfig").setup()
    require("mason-lspconfig").setup_handlers {
      function(server_name)
        ---@diagnostic disable-next-line: undefined-field
        lspconfig[server_name].setup {
          capabilities = require('blink.cmp').get_lsp_capabilities(),
        }
      end,
      ["lua_ls"] = function()
        lspconfig["lua_ls"].setup(
          require("plugins.lspconfig.lua_ls")
        )
      end,
      ['rust_analyzer'] = function() end,
    }
  end
}
