local present, cmp = pcall(require, "cmp")
local lspkind = require "lspkind"

if not present then
  return
end

vim.opt.completeopt = "menu,menuone,noselect"

cmp.setup {
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
    end,
  },
  mapping = require("core.mappings").cmp(cmp),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "vsnip" }, -- For vsnip users.
  }, {
    { name = "buffer" },
  }, {
    {
      name = "dictionary",
      keyword_length = 2,
    },
  }),
  formatting = {
    format = lspkind.cmp_format {
      with_text = true,
      maxwidth = 50,
      before = function(entry, vim_item)
        vim_item.menu = ({
          nvim_lsp = "[LSP]",
          nvim_lua = "[Lua]",
          buffer = "[BUF]",
        })[entry.source.name]
        return vim_item
      end,
    },
  },
}

-- Set configuration for specific filetype.
cmp.setup.filetype("gitcommit", {
  sources = cmp.config.sources({
    { name = "cmp_git" }, -- You can specify the `cmp_git` source if you were installed it.
  }, {
    { name = "buffer" },
  }),
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline("/", {
  sources = {
    { name = "buffer" },
  },
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
  sources = cmp.config.sources({
    { name = "path" },
  }, {
    { name = "cmdline" },
  }),
})

require("cmp_dictionary").setup {
  dic = {
    ["*"] = { "/usr/share/dict/words" },
  },
  -- The following are default values, so you don't need to write them if you don't want to change them
  exact = 2,
  first_case_insensitive = false,
  async = false,
  capacity = 5,
  debug = false,
}
