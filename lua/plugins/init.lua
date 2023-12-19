local present, lazy = pcall(require, "plugins.lazy")

if not present then
  return
end
-- install plugins
local install_plugins = {
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
    enabled = false,
    "ellisonleao/gruvbox.nvim",
    config = function()
      require("gruvbox").setup({
        undercurl = true,
        underline = true,
        bold = true,
        italic = true,
        strikethrough = true,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        invert_intend_guides = false,
        inverse = true,    -- invert background for search, diffs, statuslines and errors
        contrast = "soft", -- can be "hard", "soft" or empty string
        palette_overrides = {},
        overrides = {},
        dim_inactive = false,
        transparent_mode = false,
      })
      vim.o.background = "light" -- or "light" for light mode
      vim.cmd([[colorscheme gruvbox]])
    end
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
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-vsnip",
      {
        "hrsh7th/vim-vsnip",
        config = function()
          vim.g.vsnip_snippet_dir = vim.fn.stdpath('config') .. "/.vsnip"
        end
      },
    },
    config = function()
      require "plugins.cmp"
    end,
  },
  { "onsails/lspkind-nvim" },
  {
    "nvim-treesitter/nvim-treesitter",
    commit = "f2778bd",
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
      config = function ()
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
    enabled = false,
    "jose-elias-alvarez/null-ls.nvim",
    config = function()
      require("plugins.nullls").setup()
    end,
    dependencies = { "nvim-lua/plenary.nvim" },
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
    "simrat39/rust-tools.nvim",
    config = function()
      require("plugins.rustools").setup()
    end
  },
  {
    'akinsho/flutter-tools.nvim',
    lazy = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'stevearc/dressing.nvim', -- optional for vim.ui.select
    },
    config = function()
      require("plugins.fluttertools").setup()
    end
  }
}
lazy.load(install_plugins)
