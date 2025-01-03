local opts = {
  keymap = {
    preset = "enter",
    ["<Tab>"] = { "select_next", 'snippet_forward', "fallback" },
    ["<S-Tab>"] = { "select_prev", 'snippet_backward', "fallback" },
  },

  appearance = {
    nerd_font_variant = 'mono'
  },
  completion = {
    trigger = {
      show_on_keyword = true,
    },
    keyword = { range = 'prefix' },
    accept = { auto_brackets = { enabled = true }, },
    list = { selection = 'auto_insert' },
    menu = {
      scrollbar = false,
      border = "rounded",
      min_width = 1,
      draw = {
        columns = {
          { "label",     "label_description", gap = 1 },
          { "kind_icon", "kind" }
        },
      }
    },
    documentation = {
      window = {
        border = "rounded",
      },
    },
  },
  -- Default list of enabled providers defined so that you can extend it
  -- elsewhere in your config, without redefining it, due to `opts_extend`
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
  },
  snippets = {
    expand = function(snippet) require('luasnip').lsp_expand(snippet) end,
    active = function(filter)
      if filter and filter.direction then
        return require('luasnip').jumpable(filter.direction)
      end
      return require('luasnip').in_snippet()
    end,
    jump = function(direction) require('luasnip').jump(direction) end,
  },
  signature = { enabled = true }
}

return opts
