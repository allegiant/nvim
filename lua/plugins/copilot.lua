local present, copilot = pcall(require, "copilot")
if not present then
  return
end

local M = {}

local opts = {
  suggestion = { enabled = false },
  panel = { enabled = false },
}

M.setup = function()
  copilot.setup(opts)
end
return M
