local opts = {
  -- lazy.nvim 的 keys 不支持 group 字段，组名须注册在 which-key spec
  spec = {
    { "<leader>a", group = "AI/Claude Code" },
    { "<leader>b", group = "Buffer" },
    { "<leader>f", group = "File" },
    { "<leader>g", group = "Git" },
    { "<leader>s", group = "Split" },
    { "<leader>t", group = "Terminal" },
  },
  plugins = {
    spelling = {
      enabled = false, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
      suggestions = 20, -- how many suggestions should be shown in the list?
    },
    presets = {
      operators = false, -- adds help for operators like d, y, ... and registers them for motion / text object completion
      motions = false, -- adds help for motions
      text_objects = false, -- help for text objects triggered after entering an operator
      windows = false, -- default bindings on <c-w>
      nav = false, -- misc bindings to work with windows
      z = false, -- bindings for folds, spelling and others prefixed with z
      g = false, -- bindings for prefixed with g
    },
  },
}

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = opts,
}
