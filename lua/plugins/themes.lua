return {
  {
    "sainnhe/gruvbox-material",
    priority = 1000,
    config = function()
      vim.opt.termguicolors = true
      vim.o.background = "light"

      -- Available values: 'hard', 'medium'(default), 'soft'
      vim.g.gruvbox_material_background = 'medium'
      vim.g.gruvbox_material_better_performance = 1
      vim.cmd [[colorscheme gruvbox-material]]
    end
  }
}
