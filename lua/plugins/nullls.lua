local null_ls = require "null-ls"
local b = null_ls.builtins

local sources = {
  -- b.diagnostics.eslint,
  -- b.code_actions.eslint,
  b.formatting.stylua.with { filetpes = { "lua" } },
  -- b.code_actions.eslint_d.with { filetpes = { "vue" } },
  -- b.diagnostics.eslint_d.with { filetpes = { "vue" } },
  b.formatting.eslint_d,

  b.formatting.rustfmt.with {
    extra_args = function(params)
      local Path = require "plenary.path"
      local cargo_toml = Path:new(params.root .. "/" .. "Cargo.toml")

      if cargo_toml:exists() and cargo_toml:is_file() then
        for _, line in ipairs(cargo_toml:readlines()) do
          local edition = line:match [[^edition%s*=%s*%"(%d+)%"]]
          if edition then
            return { "--edition=" .. edition }
          end
        end
      end
      -- default edition when we don't find `Cargo.toml` or the `edition` in it.
      return { "--edition=2021" }
    end,
  },
}

local M = {}

M.setup = function()
  null_ls.setup {
    debug = false,
    sources = sources,
  }
end

return M
