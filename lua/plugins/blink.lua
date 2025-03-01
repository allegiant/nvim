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
  fuzzy = {
    -- Controls which implementation to use for the fuzzy matcher.
    --
    -- 'prefer_rust_with_warning' (Recommended) If available, use the Rust implementation, automatically downloading prebuilt binaries on supported systems. Fallback to the Lua implementation when not available, emitting a warning message.
    -- 'prefer_rust' If available, use the Rust implementation, automatically downloading prebuilt binaries on supported systems. Fallback to the Lua implementation when not available.
    -- 'rust' Always use the Rust implementation, automatically downloading prebuilt binaries on supported systems. Error if not available.
    -- 'lua' Always use the Lua implementation, doesn't download any prebuilt binaries
    --
    -- See the prebuilt_binaries section for controlling the download behavior
    implementation = 'prefer_rust_with_warning',

    -- Allows for a number of typos relative to the length of the query
    -- Set this to 0 to match the behavior of fzf
    -- Note, this does not apply when using the Lua implementation.
    max_typos = function(keyword) return math.floor(#keyword / 4) end,

    -- Frecency tracks the most recently/frequently used items and boosts the score of the item
    -- Note, this does not apply when using the Lua implementation.
    use_frecency = true,

    -- Proximity bonus boosts the score of items matching nearby words
    -- Note, this does not apply when using the Lua implementation.
    use_proximity = true,

    -- UNSAFE!! When enabled, disables the lock and fsync when writing to the frecency database. This should only be used on unsupported platforms (i.e. alpine termux)
    -- Note, this does not apply when using the Lua implementation.
    use_unsafe_no_lock = false,

    -- Controls which sorts to use and in which order, falling back to the next sort if the first one returns nil
    -- You may pass a function instead of a string to customize the sorting
    sorts = { 'score', 'sort_text' },

    prebuilt_binaries = {
      -- Whether or not to automatically download a prebuilt binary from github. If this is set to `false`,
      -- you will need to manually build the fuzzy binary dependencies by running `cargo build --release`
      -- Disabled by default when `fuzzy.implementation = 'lua'`
      download = true,

      -- Ignores mismatched version between the built binary and the current git sha, when building locally
      ignore_version_mismatch = false,

      -- When downloading a prebuilt binary, force the downloader to resolve this version. If this is unset
      -- then the downloader will attempt to infer the version from the checked out git tag (if any).
      --
      -- Beware that if the fuzzy matcher changes while tracking main then this may result in blink breaking.
      force_version = nil,

      -- When downloading a prebuilt binary, force the downloader to use this system triple. If this is unset
      -- then the downloader will attempt to infer the system triple from `jit.os` and `jit.arch`.
      -- Check the latest release for all available system triples
      --
      -- Beware that if the fuzzy matcher changes while tracking main then this may result in blink breaking.
      force_system_triple = nil,

      -- Extra arguments that will be passed to curl like { 'curl', ..extra_curl_args, ..built_in_args }
      extra_curl_args = {}
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
