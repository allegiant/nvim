return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  keys = {
    { "gj", "<cmd>lua vim.diagnostic.goto_next()<cr>",              desc = "diagnostic next" },
    { "gk", "<cmd>lua vim.diagnostic.goto_prev()<cr>",              desc = "diagnostic prev" },
    { "gr", "<cmd>lua vim.lsp.buf.rename()<cr>",                    desc = "rename" },
    { "gh", "<cmd>lua vim.lsp.buf.hover({border = 'rounded'})<CR>", desc = "Doc Hover" },

  },
  config = function()
    vim.diagnostic.config({
      virtual_text = {
        prefix = "●", -- Could be '●', '▎', 'x', ■
        spacing = 4,
      },
      float = { border = "rounded" },
      signs = {
        text = {
          [vim.diagnostic.severity.HINT] = "",
          [vim.diagnostic.severity.INFO] = "",
          [vim.diagnostic.severity.WARN] = "",
          [vim.diagnostic.severity.ERROR] = "",
        },
      },
    })
    require("lsp.lua_ls").setup()
    require("lsp.jsonls").setup()
    require("lsp.pylsp").setup()
    require("lsp.vue_ls").setup()
    require("lsp.sqls").setup()
  end,
}
