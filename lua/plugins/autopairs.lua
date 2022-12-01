local present, autopairs = pcall(require, "nvim-autopairs")
if not present then
  return
end

local function cmp_setting()
  autopairs.setup({
    check_ts = true,
  })

  local cmp_autopairs = require('nvim-autopairs.completion.cmp')
  local cmp = require('cmp')
  cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())

  local Rule = require("nvim-autopairs.rule")
  autopairs.add_rules({
    Rule("|","|","rust"),
  })
end

local M = {}

local default = {

}

M.setup = function()
  autopairs.setup(default)
  cmp_setting()
end
return M
