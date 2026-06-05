local M = {}

M.open = function()
  Snacks.explorer()
end

M.options = function(opts)
  return vim.tbl_deep_extend("force", {
    enabled = true,
  }, opts or {})
end

M.picker_options = function(opts)
  return vim.tbl_deep_extend("force", {
    enabled = true,
    sources = {
      explorer = {
        win = {
          input = {
            keys = {
              ["q"] = false,
            },
          },
          list = {
            keys = {
              ["o"] = "confirm",
              ["q"] = false,
            },
          },
          preview = {
            keys = {
              ["q"] = false,
            },
          },
        },
      },
    },
  }, opts or {})
end

return M
