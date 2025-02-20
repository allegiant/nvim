local opts = {
  keymap = {
    preset = "enter",
    ["<Tab>"] = { "select_next", 'snippet_forward', "fallback" },
    ["<S-Tab>"] = { "select_prev", 'snippet_backward', "fallback" },
  },

  appearance = {
    use_nvim_cmp_as_default = true,
    nerd_font_variant = "mono",
  },
  completion = {
    trigger = {
      show_on_keyword = true,
      prefetch_on_insert = false, --防止在行最前面按<tab>触发补全
    },
    keyword = { range = 'prefix' },
    accept = { auto_brackets = { enabled = true }, },
    list = {
      selection = {
        preselect = false,
        auto_insert = true
      }
    },
    menu = {
      border = "single",
      min_width = 1,
      draw = {
        columns = {
          { "label",     "label_description", gap = 1 },
          { "kind_icon", "kind" }
        },
      },
      auto_show = function(ctx)
        return ctx.mode ~= "cmdline" or not vim.tbl_contains({ '/', '?' }, vim.fn.getcmdtype())
      end,
    },
    documentation = {
      window = {
        border = "single",
      },
    },
  },
  -- Default list of enabled providers defined so that you can extend it
  -- elsewhere in your config, without redefining it, due to `opts_extend`
  sources = {
    default = { "lsp", "path", "snippets", "buffer", "copilot" },
    providers = {
      copilot = {
        name = "copilot",
        module = "blink-copilot",
        score_offset = 100,
        async = true,
        opts = {
          -- Local options override global ones
          -- Final settings: max_completions = 3, max_attempts = 2, kind = "Copilot"
          max_completions = 3, -- Override global max_completions
        }
      },
    },
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

return {
  {
    'saghen/blink.cmp',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        version = 'v2.*',
        dependencies = {
          'rafamadriz/friendly-snippets'
        },
      },
      {
        "fang2hou/blink-copilot",
        opts = {
          max_completions = 1, -- Global default for max completions
          max_attempts = 2,    -- Global default for max attempts
          -- `kind` is not set, so the default value is "Copilot"
        }
      },
    },
    version = '*',
    opts = opts,
    opts_extend = { "sources.default" }
  },
}
