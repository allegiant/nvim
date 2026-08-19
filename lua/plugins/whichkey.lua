-- lazy.nvim 的 keys 不支持 group 字段,组名须注册在 which-key spec
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    spec = {
      { "<leader>b", group = "Buffer" },
      { "<leader>f", group = "File" },
      { "<leader>g", group = "Git" },
      { "<leader>m", group = "Markdown" },
      { "<leader>s", group = "Split" },
      { "<leader>t", group = "Terminal" },
    },
    plugins = {
      spelling = { enabled = false }, -- z= 拼写建议不弹 which-key
      -- 不为内置操作符/动作/文本对象/窗口导航等生成帮助
      presets = {
        operators = false,
        motions = false,
        text_objects = false,
        windows = false,
        nav = false,
        z = false,
        g = false,
      },
    },
  },
}
