local present, autopairs = pcall(require, "nvim-autopairs")

if not present then
  return
end


local cmp_autopairs = require('nvim-autopairs.completion.cmp')
local cmp = require('cmp')
cmp.event:on(
  'confirm_done',
  cmp_autopairs.on_confirm_done()
)

local M = {}
local keymaps = require('core.mappings').autopairs();
local default = {
  enable_check_bracket_line = true,
  fast_wrap = {
    map = keymaps.map,
    chars = { '{', '[', '(', '"', "'" },
    pattern = [=[[%'%"%)%>%]%)%}%,]]=],
    end_key = '$',
    keys = 'qwertyuiopzxcvbnmasdfghjkl',
    check_comma = true,
    highlight = 'Search',
    highlight_grey = 'Comment'
  },
}


M.setup = function()
  autopairs.setup(default)
end
return M
