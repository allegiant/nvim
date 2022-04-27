local present, nvimtree = pcall(require, "nvim-tree")

if not present then
  return
end

local g = vim.g

g.nvim_tree_git_hl = 1
g.nvim_tree_highlight_opened_files = 1
g.nvim_tree_root_folder_modifier = table.concat { ":t:gs?$?/..", string.rep(" ", 1000), "?:gs?^??" }
g.nvim_tree_add_trailing = 1 -- append a trailing slash to folder names

g.nvim_tree_show_icons = {
  folders = 1,
  files = 1,
  git = 1,
  folder_arrows = 1
}

g.nvim_tree_icons = {
  default = "",
  symlink = "",
  git = {
    deleted = "",
    ignored = "◌",
    renamed = "➜",
    staged = "✓",
    unmerged = "",
    unstaged = "✗",
    untracked = "★",
  },
  folder = {
    default = "",
    empty = "",
    empty_open = "",
    open = "",
    symlink = "",
    symlink_open = "",
  },
}

local default = {
  auto_reload_on_write = true,
  disable_netrw = true,
  hijack_cursor = true,
  hijack_netrw = true,
  hijack_unnamed_buffer_when_opening = false,
  ignore_buffer_on_setup = false,
  open_on_setup = false,
  open_on_setup_file = false,
  open_on_tab = false,
  sort_by = "name",
  update_cwd = false,
  update_focused_file = {
    enable = true,
    update_cwd = false,
  },
  view = {
    side = "left",
    width = 25,
    hide_root_folder = true,
    number = true,
    relativenumber = true,
  },
  git = {
    enable = false,
    ignore = false,
  },
  renderer = {
    indent_markers = {
      enable = true,
    },
  },
  ignore_ft_on_setup = { "dashboard" },
  filters = {
    dotfiles = false,
  },
}

local M = {}

M.setup = function()
  nvimtree.setup(default)
end

return M
