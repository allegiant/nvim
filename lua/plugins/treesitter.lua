local parsers = {
  "lua",
  "vim",
  "html",
  "css",
  "javascript",
  "typescript",
  "tsx",
  "json",
  "markdown",
  "markdown_inline",
  "vue",
  "rust",
}

local filetypes = {
  "lua",
  "vim",
  "html",
  "css",
  "javascript",
  "javascriptreact",
  "typescript",
  "typescriptreact",
  "json",
  "markdown",
  "vue",
  "rust",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ok, treesitter = pcall(require, "nvim-treesitter")
      if not ok then
        return
      end

      local installed = treesitter.get_installed("parsers")
      local missing = vim.tbl_filter(function(parser)
        return not vim.list_contains(installed, parser)
      end, parsers)

      if #missing > 0 then
        pcall(treesitter.install, missing)
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true }),
        pattern = filetypes,
        callback = function(args)
          local started = pcall(vim.treesitter.start, args.buf)
          if started then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-ts-autotag").setup({
        opts = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = false,
        },
      })
    end,
  },
}
