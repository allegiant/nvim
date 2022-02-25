local null_ls = require "null-ls"
local b = null_ls.builtins

local sources = {
  -- b.diagnostics.eslint,
  -- b.code_actions.eslint,
  b.formatting.stylua.with { filetpes = { "lua" } },
  -- b.code_actions.eslint_d.with { filetpes = { "vue" } },
  -- b.diagnostics.eslint_d.with { filetpes = { "vue" } },
  b.formatting.eslint_d,
}

local M = {}

M.setup = function()
  null_ls.setup {
    debug = false,
    sources = sources,
  }
end

return M
