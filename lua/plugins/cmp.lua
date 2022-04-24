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
  sources = cmp.config.sources(
  {
    { name = "nvim_lsp" },
    { name = "vsnip" }, -- For vsnip users.
    { name = 'nvim_lsp_signature_help' },
  },
  {
    { name = "buffer" },
  }
  ),
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


-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline("/", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = "buffer" },
  },
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = "path" },
  }, {
    { name = "cmdline" },
  }),
})
