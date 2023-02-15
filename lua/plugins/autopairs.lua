local present, autopairs = pcall(require, "nvim-autopairs")
if not present then
  return
end

local function cmp_setting()
  autopairs.setup({
      check_ts = true,
      ts_config = {
          rust = {},
      },
  })

  local cmp_autopairs = require('nvim-autopairs.completion.cmp')
  local cmp = require('cmp')
  cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())

  local Rule = require("nvim-autopairs.rule")
  local ts_conds = require("nvim-autopairs.ts-conds")
  autopairs.add_rules({
      Rule("|", "|", "rust"),
  })
  autopairs.get_rule("'")[2]:with_pair(ts_conds.is_not_ts_node({ "type_arguments", "bounded_type" })) -- rust life
end

local M = {}

local default = {

}

M.setup = function()
  autopairs.setup(default)
  cmp_setting()
end
return M
