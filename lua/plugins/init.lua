local fn = vim.fn
local cmd = vim.cmd


local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
local packer_bootstrap
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
end

-- Only required if you have packer configured as `opt`
cmd [[packadd packer.nvim]]

return require("packer").startup(function(use)
  use "wbthomason/packer.nvim"

  use {
    "kyazdani42/nvim-tree.lua",
    requires = {
      "kyazdani42/nvim-web-devicons", -- optional, for file icon
    },
    event = 'VimEnter',
    config = function()
      require("plugins.nvimtree").setup()
      require("core.mappings").nvimtree()
    end,
  }
  use {
    disable = true,
    "ellisonleao/gruvbox.nvim",
    config = function()
      vim.opt.termguicolors = true
      vim.o.background = "light" -- or "light" for light mode
      vim.cmd [[colorscheme gruvbox]]
    end,
  }

  use {
    "sainnhe/gruvbox-material",
    config = function()
      vim.opt.termguicolors = true
      vim.o.background = "light"
      vim.g.gruvbox_material_background = 'soft'
      vim.g.gruvbox_material_better_performance = 1
      vim.cmd [[colorscheme gruvbox-material]]
    end,
  }

  use {
    'akinsho/flutter-tools.nvim',
    requires = 'nvim-lua/plenary.nvim'
  }

  use { 'stevearc/dressing.nvim' }

  use {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    {
      "neovim/nvim-lspconfig",
      config = function()
        require("plugins.lspconfig").setup()
      end
    }
  }

  use "hrsh7th/cmp-nvim-lsp"
  use "hrsh7th/cmp-buffer"
  use "hrsh7th/cmp-path"
  use "hrsh7th/cmp-cmdline"
  use "hrsh7th/cmp-nvim-lua"
  use "hrsh7th/cmp-nvim-lsp-signature-help"
  use {
    "hrsh7th/nvim-cmp",
    config = function()
      require "plugins.cmp"
    end,
  }
  use { "hrsh7th/cmp-vsnip" }
  use {
    "hrsh7th/vim-vsnip",
    config = function()
      vim.g.vsnip_snippet_dir = vim.fn.stdpath('config') .. "/.vsnip"
    end
  }

  use { "onsails/lspkind-nvim" }

  use {
    "nvim-treesitter/nvim-treesitter",
    config = function()
      require("plugins.treesitter").setup()
    end,
    requires = {
      "JoosepAlviste/nvim-ts-context-commentstring",
      "windwp/nvim-ts-autotag",
    },
    run = ":TSUpdate",
  }
  use {
    "windwp/nvim-autopairs",
    config = function()
      require("plugins.autopairs").setup()
    end,
  }
  use {
    "jose-elias-alvarez/null-ls.nvim",
    config = function()
      require("plugins.nullls").setup()
    end,
    requires = { "nvim-lua/plenary.nvim" },
  }

  use {
    "akinsho/bufferline.nvim",
    requires = { "kyazdani42/nvim-web-devicons", 'famiu/bufdelete.nvim' },
    event = 'VimEnter',
    config = function()
      require("plugins.bufferline").setup()
      require("core.mappings").bufferline()
    end,
  }

  use {
    "nvim-lualine/lualine.nvim",
    requires = {
      "kyazdani42/nvim-web-devicons",
      "arkav/lualine-lsp-progress",
      opt = true,
    },
    config = function()
      require("plugins.lualine").setup()
    end,
  }
  use {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  }
  use {
    "lewis6991/gitsigns.nvim",
    requires = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("plugins.gitsigns").setup()
    end,
  }
  use {
    "nvim-telescope/telescope.nvim",
    requires = { { "nvim-lua/plenary.nvim" } },
    config = function()
      require("plugins.telescope").setup()
    end,
  }
  use {
    "folke/which-key.nvim",
    config = function()
      require("plugins.whichkey").setup()
    end,
  }
  use {
    "akinsho/toggleterm.nvim",
    config = function()
      require("plugins.toggleterm").setup()
    end,
  }
  use {
    -- "kkharji/lspsaga.nvim",
    "glepnir/lspsaga.nvim",
    branch = "main",
    config = function()
      require("plugins.lspsaga").setup()
    end,
    setup = function()
      require("core.mappings").lspsaga()
    end,
  }
  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require("packer").sync()
  end
end)
