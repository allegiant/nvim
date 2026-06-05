local M = {}

M.open = function()
  Snacks.explorer()
end

M.options = function(opts)
  return vim.tbl_deep_extend("force", {
    enabled = true,
  }, opts or {})
end

return M
