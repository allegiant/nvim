local lsp_utils = require("lsp.utils")

local opts = {
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
        path = {
          "lua/?.lua",
          "lua/?/init.lua",
        },
      },
      diagnostics = {
        enable = true,
        globals = { "hs", "vim", "it", "describe", "before_each", "after_each" },
        disable = { "lowercase-global", "miss-parameter", "missing-parameter" },
      },
      telemetry = {
        enable = false,
      },
      format = {
        enable = true,
        defaultConfig = {
          indent_style = "space",
          indent_size = "4",
        }
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME
        }
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
