local opts = {
  keymap = {
    preset = "enter",
    ["<Tab>"] = { "select_next", 'snippet_forward', "fallback" },
    ["<S-Tab>"] = { "select_prev", 'snippet_backward', "fallback" },
  },

  appearance = {
    -- Blink does not expose its default kind icons so you must copy them all (or set your custom ones) and add Copilot
    kind_icons = {
      Copilot = "",
      Text = '󰉿',
      Method = '󰊕',
      Function = '󰊕',
      Constructor = '󰒓',

      Field = '󰜢',
      Variable = '󰆦',
      Property = '󰖷',

      Class = '󱡠',
      Interface = '󱡠',
      Struct = '󱡠',
      Module = '󰅩',

      Unit = '󰪚',
      Value = '󰦨',
      Enum = '󰦨',
      EnumMember = '󰦨',

      Keyword = '󰻾',
      Constant = '󰏿',

      Snippet = '󱄽',
      Color = '󰏘',
      File = '󰈔',
      Reference = '󰬲',
      Folder = '󰉋',
      Event = '󱐋',
      Operator = '󰪚',
      TypeParameter = '󰬛',
    },
  },
  completion = {
    trigger = {
      show_on_keyword = true,
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
    default = { "lsp", "path", "snippets", "buffer", "copilot" },
    providers = {
      copilot = {
        name = "copilot",
        module = "blink-cmp-copilot",
        score_offset = 100,
        async = true,
        transform_items = function(_, items)
          local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
          local kind_idx = #CompletionItemKind + 1
          CompletionItemKind[kind_idx] = "Copilot"
          for _, item in ipairs(items) do
            item.kind = kind_idx
          end
          return items
        end,
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

return opts
