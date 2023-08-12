local lspconfig_common = require("plugins.lspconfig.common")
local ok, rt = pcall(require, "rust-tools")
if not ok then
  return
end

local M = {}

local opts = {
  tools = {
    reload_workspace_from_cargo_toml = true,
    inlay_hints = {
      auto = true,
      only_current_line = false,
      show_parameter_hints = true,
      parameter_hints_prefix = "<- ",
      other_hints_prefix = "=> ",
      -- whether to align to the length of the longest line in the file
      max_len_align = false,
      -- padding from the left if max_len_align is true
      max_len_align_padding = 1,
      -- whether to align to the extreme right or not
      right_align = false,
      -- padding from the right if right_align is true
      right_align_padding = 7,
      -- The color of the hints
      highlight = "Comment",
    },
  },
  -- see https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#rust_analyzer
  server = {
    cmd = {"ra-multiplex","client" },
    -- on_attach is a callback called when the language server attachs to the buffer
    --  on_attach = function(_, bufnr)
    --   require("core.mappings").lspconfig(bufnr)
    --    -- Hover actions
    -- vim.keymap.set("n", "ga", rt.hover_actions.hover_actions, { buffer = bufnr })
    --    -- Code action groups
    --    vim.keymap.set("n", "<Leader>ga", rt.code_action_group.code_action_group, { buffer = bufnr })
    --  end,
    on_attach = lspconfig_common.on_attach,
    capabilities = lspconfig_common.capabilities(),

    -- standalone file support
    -- setting it to false may improve startup time
    standalone = true,
    settings = {
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
        cachePriming = {
          enable = false,
        }
      }
    },
  },
}

M.setup = function()
  require("rust-tools").setup(opts)
end

return M
