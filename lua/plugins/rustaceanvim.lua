return {
  'mrcjkb/rustaceanvim',
  version = '^5', -- Recommended
  config = function()
    vim.g.rustaceanvim = {
      server = {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      },
      dap = {

      }
    }
  end
}
