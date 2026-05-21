local lsp_utils = require("lsp.utils")

local opts = {
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        -- "Lua 5.1","Lua 5.2","Lua 5.3","Lua 5.4","LuaJIT"
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
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME
          -- Depending on the usage, you might want to add additional paths
          -- here.
          -- '${3rd}/luv/library'
          -- '${3rd}/busted/library'
        }
        -- Or pull in all of 'runtimepath'.
        -- NOTE: this is a lot slower and will cause issues when working on
        -- your own configuration.
        -- See https://github.com/neovim/nvim-lspconfig/issues/3189
        -- library = {
        --   vim.api.nvim_get_runtime_file('', true),
        -- }
      }
    },
  }
}

local M = {}

M.setup = function()
  if not lsp_utils.is_mason_package_installed("lua-language-server") then
    return
  end

  vim.lsp.config('lua_ls', opts)
  vim.lsp.enable('lua_ls')
end

return M
