local M = {}

-- snacks setup 的 terminal 默认配置;
-- Snacks.terminal.* 调用时以此为基础合并 (Snacks.config.get)
M.terminal_opts = {
  win = {
    position = "bottom",
    height = 10,
    keys = {
      term_toggle = {
        [[<C-\>]],
        function(term)
          term:toggle()
        end,
        mode = "t",
        desc = "Toggle terminal",
      },
    },
  },
}

M.toggle = function()
  Snacks.terminal.toggle()
end

-- 会话内计数,count 递增即开新终端;增量会与 setup 配置合并
local term_count = 1

M.toggle_next = function()
  term_count = term_count + 1
  Snacks.terminal.toggle(nil, { count = term_count })
end

return M
