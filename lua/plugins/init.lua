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
    "neoclide/coc.nvim",
    branch = "release",
  }

  use {
    "nvim-treesitter/nvim-treesitter",
    config = function()
      require("plugins.treesitter").setup()
    end,
    run = ":TSUpdate",
  }
  use {
    disable = true,
    "windwp/nvim-autopairs",
    config = function()
      require("plugins.autopairs").setup()
    end,
  }
  use {
    disable = true,
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
    disable = true,
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
      -- "arkav/lualine-lsp-progress",
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
  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require("packer").sync()
  end
end)
