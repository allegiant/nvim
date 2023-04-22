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
  -- auto_reload_on_write = true,
  -- disable_netrw = true,
  -- hijack_cursor = true,
  -- hijack_netrw = true,
  -- hijack_unnamed_buffer_when_opening = false,
  -- ignore_buffer_on_setup = false,
  -- open_on_setup = false,
  -- open_on_setup_file = false,
  -- open_on_tab = false,
  -- sort_by = "name",
  -- update_cwd = false,
  -- update_focused_file = {
  --   enable = true,
  --   update_cwd = false,
  -- },
  -- view = {
  --   side = "left",
  --   width = 40,
  --   hide_root_folder = true,
  --   number = true,
  --   relativenumber = true,
  -- },
  git = {
    enable = false,
    ignore = false,
  },
  -- renderer = {
  --   add_trailing = true,
  --   indent_markers = {
  --     enable = true,
  --     icons = {
  --       corner = "└ ",
  --       edge = "│ ",
  --       none = "  ",
  --     },
  --   },
  --   icons = {
  --     webdev_colors = true,
  --     git_placement = "before",
  --     padding = " ",
  --     symlink_arrow = " ➛ ",
  --     show = {
  --       file = true,
  --       folder = true,
  --       folder_arrow = true,
  --       git = true,
  --     },
  --     glyphs = {
  --       default = "",
  --       symlink = "",
  --       folder = {
  --         arrow_closed = "",
  --         arrow_open = "",
  --         default = "",
  --         open = "",
  --         empty = "",
  --         empty_open = "",
  --         symlink = "",
  --         symlink_open = "",
  --       },
  --       git = {
  --         unstaged = "✗",
  --         staged = "✓",
  --         unmerged = "",
  --         renamed = "➜",
  --         untracked = "★",
  --         deleted = "",
  --         ignored = "◌",
  --       },
  --     },
  --   },
  --   special_files = { "Cargo.toml", "Makefile", "README.md", "readme.md" },
  --   highlight_git = true,
  --   highlight_opened_files = "none",
  --   root_folder_modifier = table.concat { ":t:gs?$?/..", string.rep(" ", 1000), "?:gs?^??" },
  -- },
  -- ignore_ft_on_setup = { "dashboard" },
  -- filters = {
  --   dotfiles = false,
  -- },
}

local M = {}

M.setup = function()
  nvimtree.setup(default)
end

return M
