local terminal = require("plugins.snacks.terminal")
local lsp_progress = require("plugins.snacks.lsp_progress")

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  keys = {
    -- buffer
    { "<leader>bd", function() Snacks.bufdelete() end,                    desc = "Close" },
    -- terminal
    { "<leader>t",  group = "Terminal" },
    { [[<C-\>]],    terminal.toggle,                                      desc = "Toggle Terminal" },
    { "<leader>tn", terminal.toggle_next,                                 desc = "New Terminal" },
    { "<leader>ts", terminal.select,                                      desc = "select Terminal" },
    -- file
    { "<leader>f",  group = "File" },
    { "<leader>ff", "<cmd>lua Snacks.picker.files()<cr>",                 desc = "Find Files" },
    { "<leader>fb", "<cmd>lua Snacks.picker.buffers()<cr>",               desc = "Find Buffers" },
    { "<leader>fh", "<cmd>lua Snacks.picker.help()<cr>",                  desc = "Find help_tags" },
    { "<leader>fw", "<cmd>lua Snacks.picker.grep()<cr>",                  desc = "Find grep_tring" },
    { "<leader>fr", "<cmd>lua Snacks.picker.resume()<cr>",                desc = "Find search history" },
    { "gf",         "<cmd>lua Snacks.picker.lsp_references()<CR>",        nowait = true,               desc = "References" },
    { "gi",         "<cmd>lua Snacks.picker.lsp_implementations()<CR>",   desc = "goto Implementation" },
    { "gd",         "<cmd>lua Snacks.picker.lsp_definitions()<CR>",       desc = "definition" },
    { "gD",         "<cmd>lua Snacks.picker.lsp_declarations()<CR>",      desc = "Declaration" },
    { "gt",         "<cmd>lua Snacks.picker.lsp_type_definitions()<CR>",  desc = "Type Definitions" },
    -- { "go",         "<cmd>lua Snacks.picker.diagnostics()<cr>",           desc = "diagnostic" },
    { "gO",         "<cmd>lua Snacks.picker.diagnostics_buffer()<cr>",    desc = "Buffer diagnostic" },
    { "gs",         "<cmd>lua Snacks.picker.lsp_symbols()<CR>",           desc = "Symbols" },
    { "gS",         "<cmd>lua Snacks.picker.lsp_workspace_symbols()<CR>", desc = "Workspace Symbols" },
    -- git
    { "<leader>g",  group = "Git" },
    { "<leader>gg", function() Snacks.lazygit.open() end,                 desc = "Lazygit" },
    { "<leader>ga", function() Snacks.git.blame_line() end,               desc = "Git Blame Line" },
    { "<leader>gb", function() Snacks.picker.git_branches() end,          desc = "Git Branches" },
    { "<leader>gl", function() Snacks.picker.git_log() end,               desc = "Git Log" },
    { "<leader>gL", function() Snacks.picker.git_log_line() end,          desc = "Git Log Line" },
    { "<leader>gs", function() Snacks.picker.git_status() end,            desc = "Git Status" },
    { "<leader>gS", function() Snacks.picker.git_stash() end,             desc = "Git Stash" },
    { "<leader>gd", function() Snacks.picker.git_diff() end,              desc = "Git Diff (Hunks)" },
    { "<leader>gF", function() Snacks.picker.git_files() end,             desc = "Git Files" },
    { "<leader>gf", function() Snacks.picker.git_log_file() end,          desc = "Git Log File" },
  },
  opts = {
    bigfile = { enabled = false },
    dashboard = {
      enabled = true,
      sections = {
        { section = "header" },
        { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
        { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
        { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
        { section = "startup" },
      },
    },
    explorer = { enabled = false },
    indent = { enabled = false },
    input = { enabled = true },
    lazygit = {
      win = {
        position = "float",
        width = 0.95,
        height = 0.95,
        border = "rounded",
      },
    },
    picker = { enabled = true },
    notifier = {
      enabled = true,
      top_down = false, -- place notifications from top to bottom
    },
    terminal = terminal.options(),
    quickfile = { enabled = false },
    scope = { enabled = false },
    scroll = { enabled = false },
    statuscolumn = { enabled = false },
    words = { enabled = false },
  },
  init = function()
    lsp_progress.setup()
  end
}
