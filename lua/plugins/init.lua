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
    "nvim-lua/plenary.nvim"
  }

  use {
    "williamboman/nvim-lsp-installer",
    {
      "neovim/nvim-lspconfig",
      config = function()
        require "plugins.lspinstaller"
        require("plugins.lspconfig").setup()
      end,
    },
  }
  use {
    "ray-x/lsp_signature.nvim",
    config = function()
      require("plugins.lsp_signature").setup()
    end
  }
  use "hrsh7th/cmp-nvim-lsp"
  use "hrsh7th/cmp-buffer"
  use "hrsh7th/cmp-path"
  use "hrsh7th/cmp-cmdline"
  use {
    "hrsh7th/nvim-cmp",
    config = function()
      require "plugins.cmp"
    end,
  }
  use { "hrsh7th/cmp-vsnip" }
  use {
    "hrsh7th/vim-vsnip",
    config =  function ()
      vim.g.vsnip_snippet_dir=vim.fn.stdpath('config').."/.vsnip"
    end
  }
  use "rafamadriz/friendly-snippets"


  use { "onsails/lspkind-nvim" }

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
      require("plugins.autopairs").setup()
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
  use {
    "akinsho/toggleterm.nvim",
    config = function()
      require("plugins.toggleterm").setup()
    end,
  }
  use {
    disable = true,
    "tami5/lspsaga.nvim",
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
