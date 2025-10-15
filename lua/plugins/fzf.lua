return {
  enabled = false,
  event = "VeryLazy",
  "ibhagwan/fzf-lua",
  -- optional for icon support
  dependencies = { "nvim-tree/nvim-web-devicons" },
  -- or if using mini.icons/mini.nvim
  -- dependencies = { "nvim-mini/mini.icons" },
  keys = {
    { "<leader>f",  group = "File" },
    { "<leader>ff", "<cmd>FzfLua files<cr>",                    desc = "Find Files" },
    { "<leader>fg", "<cmd>FzfLua live_grep<cr>",                desc = "Find live_grep" },
    { "<leader>fb", "<cmd>FzfLua buffers<cr>",                  desc = "Find Buffers" },
    { "<leader>fh", "<cmd>FzfLua helptags<cr>",                 desc = "Find help_tags" },
    { "<leader>fw", "<cmd>FzfLua grep<cr>",                     desc = "Find grep_tring" },
    { "<leader>fr", "<cmd>FzfLua resume<cr>",                   desc = "Find search history" },
    { "gf",         "<cmd>FzfLua lsp_finder<CR>",               desc = "Ref + Impl" },
    { "gd",         "<cmd>FzfLua  lsp_definitions<CR>",         desc = "definition" },
    { "gt",         "<cmd>FzfLua lsp_typedefs<CR>",             desc = "Type Definitions" },
    { "go",         "<cmd>FzfLua lsp_document_diagnostics<cr>", desc = "Show diagnostic" },
    { "gi",         "<cmd>FzfLua lsp_incoming_calls<CR>",       desc = "incoming calls" },
    { "gu",         "<cmd>FzfLua lsp_outgoing_calls<CR>",       desc = "outgoing calls" },
    { "gs",         "<cmd>FzfLua lsp_document_symbols<CR>",     desc = "Document Symbols" },
    { "gS",         "<cmd>FzfLua lsp_workspace_symbols<CR>",    desc = "Workspace Symbols" },
  },
  config = function()
    require('fzf-lua').register_ui_select()
  end
}
