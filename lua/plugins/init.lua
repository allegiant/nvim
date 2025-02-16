local present, lazy = pcall(require, "plugins.lazy")
if not present then
  return
end
-- install plugins
local install_plugins = {
  {
    'stevearc/dressing.nvim',
    opts = {},
  },
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    event = 'VimEnter',
    config = function()
      require("plugins.nvimtree").setup()
      require("core.mappings").nvimtree()
    end,
  },
  {
    enabled = true,
    "sainnhe/gruvbox-material",
    config = function()
      vim.opt.termguicolors = true
      vim.o.background = "light"
      vim.g.gruvbox_material_background = 'soft'
      vim.g.gruvbox_material_better_performance = 1
      vim.cmd [[colorscheme gruvbox-material]]
    end,
  },
  {
    "williamboman/mason.nvim",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      {
        "neovim/nvim-lspconfig",
        config = function()
          require("plugins.lspconfig").setup()
        end
      },
    }
  },

  { "onsails/lspkind-nvim" },
  {
    "nvim-treesitter/nvim-treesitter",
    config = function()
      require("plugins.treesitter").setup()
    end,
    dependencies = {
      "windwp/nvim-ts-autotag",
    },
    build = ":TSUpdate",
  },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    config = function()
      require('ts_context_commentstring').setup()
    end
  },
  {
    "windwp/nvim-autopairs",
    config = function()
      require("plugins.autopairs").setup()
    end,
  },
  {
    "akinsho/bufferline.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      'famiu/bufdelete.nvim'
    },
    event = 'VimEnter',
    config = function()
      require("plugins.bufferline").setup()
      require("core.mappings").bufferline()
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "arkav/lualine-lsp-progress",
    },
    config = function()
      require("plugins.lualine").setup()
    end,
  },
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("plugins.gitsigns").setup()
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    branch = '0.1.x',
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("plugins.telescope").setup()
    end,
  },
  {
    "folke/which-key.nvim",
    config = function()
      require("plugins.whichkey").setup()
    end,
  },
  {
    "akinsho/toggleterm.nvim",
    config = function()
      require("plugins.toggleterm").setup()
    end,
  },
  {
    "glepnir/lspsaga.nvim",
    event = "BufRead",
    config = function()
      require("plugins.lspsaga").setup()
    end,
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
      --Please make sure you install markdown and markdown_inline parser
      { "nvim-treesitter/nvim-treesitter" }
    },
    init = function()
      require("core.mappings").lspsaga()
    end,
  },
  {
    'akinsho/flutter-tools.nvim',
    lazy = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'stevearc/dressing.nvim', -- optional for vim.ui.select
      'dart-lang/dart-vim-plugin',
    },
    config = function()
      require("plugins.fluttertools").setup()
    end
  },
  {
    'mrcjkb/rustaceanvim',
    version = '^5', -- Recommended
    lazy = false,   -- This plugin is already lazy
    config = function()
      vim.g.rustaceanvim = require('plugins.rustaceanvim').config
    end
  },
  {
    "coffebar/neovim-project",
    opts = require("plugins.project"),
    init = function()
      -- enable saving the state of plugins in the session
      vim.opt.sessionoptions:append("globals") -- save global variables that start with an uppercase letter and contain at least one lowercase letter.
    end,
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-telescope/telescope.nvim", branch = "0.1.x" },
      { "Shatur/neovim-session-manager" },
    },
    lazy = false,
    priority = 100,
  },
  {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    config = function()
      require('dashboard').setup {
        -- config
      }
    end,
    dependencies = { { 'nvim-tree/nvim-web-devicons' } }
  },
  {
    'saghen/blink.compat',
    -- use the latest release, via version = '*', if you also use the latest release for blink.cmp
    version = '*',
    -- lazy.nvim will automatically load the plugin when it's required by blink.cmp
    lazy = true,
    -- make sure to set opts so that lazy.nvim calls blink.compat's setup
    opts = {},
  },
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
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        config = function()
          require('plugins.copilot').setup()
        end
      },
      "giuxtaposition/blink-cmp-copilot"
    },
    version = '*',
    opts = require('plugins.blink'),
    opts_extend = { "sources.default" }
  },
  {
    'saghen/blink.nvim',
  },
  {
    'wa11breaker/flutter-bloc.nvim',
    dependencies = {
      "nvimtools/none-ls.nvim", -- Required for code actions
    },
    opts = {
      bloc_type = 'equatable', -- Choose from: 'default', 'equatable', 'freezed'
      use_sealed_classes = false,
      enable_code_actions = true,
    }
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text"
    },
    config = function()
      require('plugins.dap').config()
    end
  },
}
lazy.load(install_plugins)
