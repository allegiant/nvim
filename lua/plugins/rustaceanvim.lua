return {
  "mrcjkb/rustaceanvim",
  version = "^7", -- Recommended
  lazy = false,
  config = function()
    vim.g.rustaceanvim = {
      server = {
        -- cmd = { "lspmux" },
        capabilities = require("blink.cmp").get_lsp_capabilities(),
        default_settings = {
          ["rust-analyzer"] = {
            diagnostics = {
              enable = true,
            },
            checkOnSave = {
              command = "check",
            },
            lru = {
              capacity = 1024,
            },
            files = {
              watcher = "client",
              excludeDirs = { ".git", ".cargo", "target", "target_ra", "node_modules" },
            },
            -- 3. 宏展开配置 (性能关键点)
            procMacro = {
              enable = true,
              -- 如果发现特定库的宏导致卡顿，可以在这里忽略它们
              -- ignored = {
              --   ["rquickjs"] = { "bindgen" }, -- 示例，具体宏名需看文档
              -- },
            },

            -- 4. Cargo 特性配置
            cargo = {
              buildScripts = {
                enable = true,
              },
              allFeatures = false,
            },

            -- 5. 补全体验优化
            completion = {
              callable = {
                snippets = "add_parentheses",
              },
            },

            -- 6. Import 自动整理
            imports = {
              -- 自动引入时尽量使用 crate:: 而不是相对路径
              granularity = {
                group = "module",
              },
              prefix = "self",
            },
            -- 7. 内嵌提示 (Inlay Hints) - 控制噪音
            -- 如果觉得屏幕太乱，可以关掉部分不重要的提示
            inlayHints = {
              bindingModeHints = { enable = false },
              chainingHints = { enable = true },
              closingBraceHints = { enable = true, minLines = 25 },
              closureReturnTypeHints = { enable = "never" },
              lifetimeElisionHints = { enable = "never" }, --通常太吵了
              parameterHints = { enable = true },
              reborrowHints = { enable = "never" },
              renderColons = true,
              typeHints = {
                enable = true,
                hideClosureInitialization = false,
                hideNamedConstructor = false,
              },
            }
          },
        },
      },

      -- dap = {},
    }
  end,
}
