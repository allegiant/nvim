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
  local cond = require("nvim-autopairs.conds")
  autopairs.add_rules({
    Rule(" ", " ")
        :with_pair(function(opts)
          local pair = opts.line:sub(opts.col - 1, opts.col)
          return vim.tbl_contains({ "()", "{}", "[]" }, pair)
        end)
        :with_move(cond.none())
        :with_cr(cond.none())
        :with_del(function(opts)
          local col = vim.api.nvim_win_get_cursor(0)[2]
          local context = opts.line:sub(col - 1, col + 2)
          return vim.tbl_contains({ "(  )", "{  }", "[  ]" }, context)
        end),
    Rule("", " )")
        :with_pair(cond.none())
        :with_move(function(opts)
          return opts.char == ")"
        end)
        :with_cr(cond.none())
        :with_del(cond.none())
        :use_key(")"),
    Rule("", " }")
        :with_pair(cond.none())
        :with_move(function(opts)
          return opts.char == "}"
        end)
        :with_cr(cond.none())
        :with_del(cond.none())
        :use_key("}"),
    Rule("", " ]")
        :with_pair(cond.none())
        :with_move(function(opts)
          return opts.char == "]"
        end)
        :with_cr(cond.none())
        :with_del(cond.none())
        :use_key("]"),
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
