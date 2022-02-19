local fn = vim.fn
local cmd = vim.cmd
local opt = vim.opt
local o = vim.o

local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
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
    "ellisonleao/gruvbox.nvim",
    config = function()
      vim.opt.termguicolors = true
      vim.o.background = "light" -- or "light" for light mode
      vim.cmd [[colorscheme gruvbox]]
    end,
  }

  use {
    "neovim/nvim-lspconfig",
    config = function()
      require("plugins.lspconfig").setup()
    end,
  }
  use {
    "williamboman/nvim-lsp-installer",
    config = function()
      require "plugins.lspinstaller"
    end,
  }
  use {
    "hrsh7th/nvim-cmp",
    config = function()
      require "plugins.cmp"
    end,
  }
  use "hrsh7th/cmp-nvim-lsp"
  use "hrsh7th/cmp-buffer"
  use "hrsh7th/cmp-path"
  use "hrsh7th/cmp-cmdline"
  use "hrsh7th/cmp-vsnip"
  use "hrsh7th/vim-vsnip"
  use "uga-rosa/cmp-dictionary"

  use "onsails/lspkind-nvim"

  use {
    "nvim-treesitter/nvim-treesitter",
    config = function()
      require("plugins.treesitter").setup()
    end,
    run = ":TSUpdate",
  }
  use {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup {}
    end,
  }
  use {
    "windwp/nvim-ts-autotag",
    requires = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("plugins.autotag").setup()
    end,
  }
  use {
    "kyazdani42/nvim-tree.lua",
    requires = {
      "kyazdani42/nvim-web-devicons", -- optional, for file icon
    },
    config = function()
      require("plugins.nvimtree").setup()
    end,
    setup = function()
      require("core.mappings").nvimtree()
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
    requires = "kyazdani42/nvim-web-devicons",
    config = function()
      require("plugins.bufferline").setup()
    end,
    setup = function()
      require("core.mappings").bufferline()
    end,
  }

  use {
    "nvim-lualine/lualine.nvim",
    requires = { "kyazdani42/nvim-web-devicons", opt = true },
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
    "JoosepAlviste/nvim-ts-context-commentstring",
    requires = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("plugins.commentstring").setup()
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
  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require("packer").sync()
  end
end)
