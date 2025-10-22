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
    keymap = {
      ['<CR>'] = { 'accept', 'fallback' },
    },
    completion = { menu = { auto_show = true } }
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
  snippets = {
    expand = function(snippet)
      require("luasnip").lsp_expand(snippet)
    end,
    active = function(filter)
      if filter and filter.direction then
        return require("luasnip").jumpable(filter.direction)
      end
      return require("luasnip").in_snippet()
    end,
    jump = function(direction)
      require("luasnip").jump(direction)
    end,
  },
  signature = { enabled = true },
}

return {
  {
    "saghen/blink.cmp",
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        dependencies = {
          "rafamadriz/friendly-snippets",
        },
        build = "make install_jsregexp"
      },
      {
        "fang2hou/blink-copilot",
      },
    },
    version = "*",
    opts = opts,
    opts_extend = { "sources.default" },
  },
  {
    "saghen/blink.pairs",
    version = "*", -- (recommended) only required with prebuilt binaries
    -- download prebuilt binaries from github releases
    dependencies = "saghen/blink.download",
    opts = {
      mappings = {
        -- you can call require("blink.pairs.mappings").enable() and require("blink.pairs.mappings").disable() to enable/disable mappings at runtime
        enabled = true,
        -- see the defaults: https://github.com/Saghen/blink.pairs/blob/main/lua/blink/pairs/config/mappings.lua#L10
        pairs = {},
      },
      highlights = {
        enabled = true,
        groups = {
          "BlinkPairsOrange",
          "BlinkPairsPurple",
          "BlinkPairsBlue",
        },
        matchparen = {
          enabled = true,
          group = "MatchParen",
        },
      },
      debug = false,
    },
  },
}
