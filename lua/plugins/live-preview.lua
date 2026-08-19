-- GitHub 风格浏览器预览;Mermaid / KaTeX 由插件内置,无需 Node
-- 不用 opts: 插件入口是 livepreview.config.set,不是 setup()
return {
  "brianhuster/live-preview.nvim",
  cmd = { "LivePreview" },
  dependencies = { "folke/snacks.nvim" },
  keys = {
    { "<leader>mp", "<cmd>LivePreview start<cr>", ft = "markdown", desc = "Markdown Preview" },
    { "<leader>mc", "<cmd>LivePreview close<cr>", desc = "Close Markdown Preview" },
    { "<leader>mf", "<cmd>LivePreview pick<cr>", desc = "Pick Markdown Preview" },
  },
  config = function()
    -- picker 留空: 这版没有实现 snacks 专用 picker,空值会自动探测
    require("livepreview.config").set({
      sync_scroll = true,
    })
  end,
}
