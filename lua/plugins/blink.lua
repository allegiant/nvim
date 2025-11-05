local opts = {
  keymap = {
    preset = "enter",
    ["<Tab>"] = {
      function(cmp)
        if cmp.is_visible() then
          return cmp.select_next()
        elseif cmp.snippet_active() then
          return cmp.snippet_forward()
        else
          return false
        end
      end,
      "fallback",
    },
    ["<S-Tab>"] = {
      function(cmp)
        if cmp.is_visible() then
          return cmp.select_prev()
        elseif cmp.snippet_active() then
          return cmp.snippet_backward()
        else
          return false
        end
      end,
      "fallback",
    },
  },
  cmdline = {
    completion = {
      list = {
        selection = {
          preselect = false,
        },
      },
      menu = { auto_show = true }
    },
  },
  appearance = {
    use_nvim_cmp_as_default = false,
    nerd_font_variant = "mono",
  },
  completion = {
    trigger = {
      show_on_keyword = true,
      prefetch_on_insert = false, --防止在行最前面按<tab>触发补全
      show_on_blocked_trigger_characters = { " ", "\n", "\t" },
    },
    keyword = { range = "prefix" },
    accept = { auto_brackets = { enabled = true } },
    list = {
      selection = {
        preselect = false,
        auto_insert = true,
      },
    },
    menu = {
      border = "single",
      min_width = 1,
      draw = {
        columns = {
          { "label",     "label_description", gap = 1 },
          { "kind_icon", "kind" },
        },
      },
    },
    documentation = {
      window = {
        border = "single",
      },
    },
  },
  fuzzy = {
    implementation = "prefer_rust_with_warning",
    max_typos = function(keyword) return math.floor(#keyword / 4) end,
    frecency = {
      enabled = true,
      path = vim.fn.stdpath('state') .. '/blink/cmp/frecency.dat',
      unsafe_no_lock = false,
    },
    use_proximity = true,
    sorts = { "score", "sort_text" },
    prebuilt_binaries = {
      download = true,
      ignore_version_mismatch = false,
      force_version = nil,
      force_system_triple = nil,
      extra_curl_args = {},
    },
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer", "copilot" },
    providers = {
      copilot = {
        name = "copilot",
        module = "blink-copilot",
        score_offset = 100,
        async = true,
      },
      cmdline = {
        min_keyword_length = function(ctx)
          -- when typing a command, only show when the keyword is 3 characters or longer
          if ctx.mode == 'cmdline' and string.find(ctx.line, ' ') == nil then return 3 end
          return 0
        end
      }
    },
  },
  signature = { enabled = true },
}

return {
  {
    "saghen/blink.cmp",
    dependencies = { "fang2hou/blink-copilot" },
    version = "*",
    opts = opts,
    opts_extend = { "sources.default" },
  },
  {
    "saghen/blink.pairs",
    version = "*",
    dependencies = "saghen/blink.download",
    opts = {
      mappings = {
        enabled = true,
        cmdline = true,
        pairs = {},
      },
      highlights = {
        enabled = true,
        cmdline = true,
        groups = {
          "BlinkPairsOrange",
          "BlinkPairsPurple",
          "BlinkPairsBlue",
        },
        unmatched_group = 'BlinkPairsUnmatched',
        matchparen = {
          enabled = true,
          cmdline = false,
          include_surrounding = false,
          group = 'BlinkPairsMatchParen',
          priority = 250,
        },
      },
      debug = false,
    },
  },
}
