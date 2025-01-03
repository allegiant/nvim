local present, nvimtree = pcall(require, "nvim-tree")

if not present then
  return
end

local default = {
  sort_by = "case_sensitive",
  view = {
    adaptive_size = true,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = false,
  },
  git = {
    enable = false,
    ignore = false,
  },
}

local M = {}

M.setup = function()
  nvimtree.setup(default)
end

return M
