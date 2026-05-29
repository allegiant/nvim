return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  keys = {
    { "gj", "<cmd>lua vim.diagnostic.jump({ count = 1, float = true })<cr>",  desc = "diagnostic next" },
    { "gk", "<cmd>lua vim.diagnostic.jump({ count = -1, float = true })<cr>", desc = "diagnostic prev" },
    { "gr", "<cmd>lua vim.lsp.buf.rename()<cr>",                    desc = "rename" },
    { "gh", "<cmd>lua vim.lsp.buf.hover({border = 'rounded'})<CR>", desc = "Doc Hover" },
    { "ga", "<cmd>lua vim.lsp.buf.code_action()<CR>",               desc = "Code Action" },
    { "go", function() vim.diagnostic.open_float() end,             desc = "diagnostics" },

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
    require("plugins.lsp.lua_ls").setup()
    require("plugins.lsp.jsonls").setup()
    require("plugins.lsp.pylsp").setup()
    require("plugins.lsp.vue_ls").setup()
    require("plugins.lsp.sqls").setup()
  end,
}
