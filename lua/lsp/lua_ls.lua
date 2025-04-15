local M = {}
M.opts = {
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = "LuaJIT",
      },
      diagnostics = {
        enable = true,
        globals = { "hs", "vim", "it", "describe", "before_each", "after_each" },
        disable = { "lowercase-global", "miss-parameter", "missing-parameter" },
      },
      -- completion = {
      --   keywordSnippet = "Disable"
      -- },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
      format = {
        enable = true,
        -- Put format options here
        -- NOTE: the value should be STRING!!
        defaultConfig = {
          indent_style = "space",
          indent_size = "4",
        }
      },
    },
  }
}


-- M.setup = function()
--   local present, mason_registry = pcall(require, "mason-registry")
--   if not present then
--     return
--   end
--
--   local installed = mason_registry.is_installed("lua-language-server")
--   if not installed then
--     return
--   end
--
--
--   vim.lsp.config('lua_ls', M.opts)
--   vim.lsp.enable('lua_ls')
-- end

return M
