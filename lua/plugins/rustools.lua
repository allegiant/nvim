local lspconfig_common = require("plugins.lspconfig.common")
local M = {}

local opts = {
  tools = {
    runnables = {
      use_telescope = true,
    },
    inlay_hints = {
      auto = true,
      show_parameter_hints = false,
      parameter_hints_prefix = "",
      other_hints_prefix = "",
    },
  },

  -- all the opts to send to nvim-lspconfig
  -- these override the defaults set by rust-tools.nvim
  -- see https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#rust_analyzer
  server = {
    -- on_attach is a callback called when the language server attachs to the buffer
    on_attach = lspconfig_common.on_attach,
    capabilities = lspconfig_common.capabilities(),
    settings = {
      -- to enable rust-analyzer settings visit:

      -- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc

      ["rust-analyzer"] = {
        rustfmt = {
          rangeFormatting = {
            enable = true
          }
        },
        imports = {
          granularity = {
            group = "module",
          },
          prefix = "self",
        },
        cargo = {
          loadOutDirsFromCheck = true,
          buildScripts = {
            enable = true,
          },
        },
        procMacro = {
          enable = true
        },
      }
    },
  },
}

M.setup = function()
  require("rust-tools").setup(opts)
end

return M
