local present, autopairs = pcall(require, "nvim-autopairs")
local Rule = require("nvim-autopairs.rule")
if not present then
  return
end

local M = {}

M.setup = function()
  autopairs.setup({
    check_ts = true,
  })

  autopairs.add_rules({
    Rule("|", "|", "rust"),
    Rule("<", ">", "rust"),
  })
end
return M
