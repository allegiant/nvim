return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      -- Customize or remove this keymap to your liking
      "<leader>fm",
      function()
        require("conform").format({ async = true })
      end,
      mode = "",
      desc = "Format buffer",
    },
  },
  opts = {
    default_format_opts = {
      lsp_format = "fallback",
    },
    -- Define your formatters
    formatters_by_ft = {
      vue = { "prettierd", "prettier" },
      html = { "prettierd", "prettier" },
      javascript = { "prettierd", "prettier" },
      javascriptreact = { "prettierd", "prettier" },
      markdown = { "prettierd", "prettier" },
      typescript = { "prettierd", "prettier" },
      typescriptreact = { "prettierd", "prettier" },
    },
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
    formatters = {
      prettierd = {
        condition = function()
          return vim.loop.fs_realpath(".prettierrc.js") ~= nil
              or vim.loop.fs_realpath(".prettierrc.mjs") ~= nil
        end,
      },
    },
  },
}
