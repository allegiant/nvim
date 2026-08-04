-- prettierd 优先,prettier 兜底;stop_after_first 避免流水线式重复格式化
local prettier = { "prettierd", "prettier", stop_after_first = true }

return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
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
    formatters_by_ft = {
      vue = prettier,
      html = prettier,
      javascript = prettier,
      javascriptreact = prettier,
      markdown = prettier,
      typescript = prettier,
      typescriptreact = prettier,
      sql = { "sqruff" }
    },
    format_on_save = {
      timeout_ms = 500,
      lsp_format = "fallback",
    },
  },
}
