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
      menu = { auto_show = true },
      -- noice-friendly shell-like preview on cmdline
      ghost_text = { enabled = true },
    },
  },
  appearance = {
    nerd_font_variant = "mono",
  },
  completion = {
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
        -- highlight LSP labels with treesitter
        treesitter = { "lsp" },
        columns = {
          { "label",     "label_description", gap = 1 },
          { "kind_icon", "kind" },
        },
      },
    },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 200,
      window = {
        border = "single",
      },
    },
  },
  fuzzy = {
    -- v2: prefer_rust_with_warning removed; use rust + build() (or lua)
    implementation = "rust",
    max_typos = function(keyword) return math.floor(#keyword / 4) end,
    frecency = {
      enabled = true,
      path = vim.fn.stdpath('state') .. '/blink/cmp/frecency.dat',
    },
    use_proximity = true,
    -- prioritize exact matches before score
    sorts = { "exact", "score", "sort_text" },
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
    providers = {
      cmdline = {
        -- Windows/git-bash/WSL: avoid hang on :! shell commands
        enabled = function()
          return vim.fn.getcmdtype() ~= ":"
              or not vim.fn.getcmdline():match("^[%%0-9,'<>%-]*!")
        end,
        min_keyword_length = function(ctx)
          -- when typing a command, only show when the keyword is 3 characters or longer
          if ctx.mode == 'cmdline' and string.find(ctx.line, ' ') == nil then return 3 end
          return 0
        end
      }
    },
  },
  signature = {
    enabled = true,
    window = { border = "single" },
  },
}

return {
  {
    "saghen/blink.cmp",
    -- v2 tracks main; drop version = "1.*" pin
    dependencies = { "saghen/blink.lib" },
    build = function()
      -- v2: no auto prebuilt_binaries; build fuzzy matcher locally
      require("blink.cmp").build():pwait(60000)
    end,
    opts = opts,
    opts_extend = { "sources.default" },
  },
  {
    "saghen/blink.pairs",
    enabled = true,
    dependencies = 'saghen/blink.lib',
    version = "*",
    build = function() require('blink.pairs').download():pwait(60000) end,
    opts = {
      mappings = {
        enabled = true,
        cmdline = true,
        disabled_filetypes = {},
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
