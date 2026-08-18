local M = {}

M.open = function()
  Snacks.explorer()
end

-- snacks setup 的 picker 配置：explorer 窗口键位
-- (禁用 q/Esc,统一用 <leader>e 开合)
M.picker_opts = {
  enabled = true,
  sources = {
    explorer = {
      hidden = true,  -- 显示 .xxx 隐藏文件/目录
      ignored = true, -- 显示 gitignore 忽略的文件
      -- 覆盖默认 explorer_yank：全路径同时写入系统剪贴板
      actions = {
        explorer_yank = function(picker)
          require("snacks.explorer.actions").actions.explorer_yank(picker)
          local src = vim.v.register
          if src == nil or src == "" then
            src = '"'
          end
          vim.fn.setreg("+", vim.fn.getreg(src), vim.fn.getregtype(src))
        end,
      },
      win = {
        input = {
          keys = {
            ["<Esc>"] = false,
            ["q"] = false,
          },
        },
        list = {
          keys = {
            ["<Esc>"] = false,
            ["o"] = "confirm",
            ["q"] = false,
          },
        },
        preview = {
          keys = {
            ["<Esc>"] = false,
            ["q"] = false,
          },
        },
      },
    },
  },
}

return M
