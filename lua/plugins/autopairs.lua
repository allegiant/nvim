local present, autopairs = pcall(require, "nvim-autopairs")

if not present then
  return
end

local function cmp_setting()
  local cmp_autopairs = require('nvim-autopairs.completion.cmp')
  local handlers = require('nvim-autopairs.completion.handlers')
  local cmp = require('cmp')
  cmp.event:on(
    'confirm_done',
    cmp_autopairs.on_confirm_done({
      filetypes = {
        -- "*" is a alias to all filetypes
        ["*"] = {
          ["("] = {
            kind = {
              cmp.lsp.CompletionItemKind.Function,
              cmp.lsp.CompletionItemKind.Method,
            },
            handler = handlers["*"]
          }
        },
        lua = {
          ["("] = {
            kind = {
              cmp.lsp.CompletionItemKind.Function,
              cmp.lsp.CompletionItemKind.Method
            },
            handler = handlers["*"]
          }
        },
        -- Disable for tex
        tex = false
      }
    })
  )
end

local M = {}

local default = {

}

M.setup = function()
  autopairs.setup(default)
  cmp_setting()
end
return M
