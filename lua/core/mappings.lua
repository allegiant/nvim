local utils = require "core.utils"
---@diagnostic disable-next-line: undefined-global
local vim = vim
local present, wk = pcall(require, "which-key")
if not present then
  return
end

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }


map("v", "<leader>y", '"+y', opts)
map("n", "<leader>y", '"+y', opts)
map("n", "<leader>Y", '"+yg_', opts)
map("n", "<leader>p", '"+p', opts)
map("n", "<leader>P", '"+P', opts)
map("v", "<leader>p", '"+p', opts)
map("v", "<leader>P", '"+P', opts)
map("v", "<leader>d", '"+d', opts)

-- move between windows
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- resizing window
map("n", "H", "<C-w>3<", opts)
map("n", "L", "<C-w>3>", opts)
map("n", "K", "<C-w>2+<", opts)
map("n", "J", "<C-w>2-", opts)

wk.add({
  { "<leader>sv", ":vsp<CR>", desc = "vertical split" },
  { "<leader>sh", ":sp<CR>",  desc = "Horizontal split" },
})
local pluginskeys = {}

pluginskeys.lspsaga = function()
  wk.add({
    { "g",  group = "Lspsaga" },
    { "gf", "<cmd>Lspsaga lsp_finder<CR>",            desc = "Definition Declaration" },
    { "ga", "<cmd>Lspsaga code_action<CR>",           desc = "Code Action",           mode = { "n", "v" } },
    { "gr", "<cmd>Lspsaga rename<CR>",                desc = "Rename",                silent = true },
    { "gd", "<cmd>Lspsaga goto_definition<CR>",       desc = "goto definition" },
    { "gt", "<cmd>Lspsaga goto_type_definition<CR>",  desc = "goto type definition" },
    { "go", "<cmd>Lspsaga show_line_diagnostics<cr>", desc = "Show line diagnostic" },
    { "gj", "<cmd>Lspsaga diagnostic_jump_next<cr>",  desc = "diagnostic next" },
    { "gk", "<cmd>Lspsaga diagnostic_jump_prev<cr>",  desc = "diagnostic prev" },
    { "gh", "<cmd>Lspsaga hover_doc<CR>",             desc = "Doc Hover" },
  })
  wk.add({
    { "<leader>l",  group = "Lspsaga" },
    { "<leader>lt", "<cmd>Lspsaga outline<CR>",                                                                           desc = "outline Toggle" },
    { "<leader>la", ":<c-u>Lspsaga range_code_action<cr>",                                                                desc = "Range Code Action",     mode = "v" },
    { "<leader>lc", "<cmd>Lspsaga show_cursor_diagnostics<CR>",                                                           desc = "Show cursor diagnostic" },
    { "<leader>lb", "<cmd>Lspsaga show_buf_diagnostics<CR>",                                                              desc = "Show buffer diagnostic" },
    { "<leader>lj", function() require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR }) end, desc = "error prev" },
    { "<leader>lk", function() require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR }) end, desc = "error next" },
    { "<leader>li", "<cmd>Lspsaga incoming_calls<CR>",                                                                    desc = "incoming calls" },
    { "<leader>lo", "<cmd>Lspsaga outgoing_calls<CR>",                                                                    desc = "outgoing calls" },
  })
end

pluginskeys.lspconfig = function(bufnr)
  wk.add({
    { "<leader>f", group = "File" },
    {
      { buffer = bufnr, silent = true,                                      noremap = true },
      { "<leader>fm",   function() vim.lsp.buf.format { async = true } end, desc = "Lsp format" },
    }
  })
end

pluginskeys.bufferline = function()
  map("n", "<TAB>", ":BufferLineCycleNext <CR>", opts)
  map("n", "<S-Tab>", ":BufferLineCyclePrev <CR>", opts)
  wk.add({
    { "<leader>",  group = "Buffer" },
    { "<leader>1", "<Cmd>BufferLineGoToBuffer 1<CR>", desc = "goto 1" },
    { "<leader>2", "<Cmd>BufferLineGoToBuffer 2<CR>", desc = "goto 2" },
    { "<leader>3", "<Cmd>BufferLineGoToBuffer 3<CR>", desc = "goto 3" },
    { "<leader>4", "<Cmd>BufferLineGoToBuffer 4<CR>", desc = "goto 4" },
    { "<leader>5", "<Cmd>BufferLineGoToBuffer 5<CR>", desc = "goto 5" },
    { "<leader>6", "<Cmd>BufferLineGoToBuffer 6<CR>", desc = "goto 6" },
    { "<leader>7", "<Cmd>BufferLineGoToBuffer 7<CR>", desc = "goto 7" },
    { "<leader>8", "<Cmd>BufferLineGoToBuffer 8<CR>", desc = "goto 8" },
    { "<leader>9", "<Cmd>BufferLineGoToBuffer 9<CR>", desc = "goto 9" },
  }, opts)

  wk.add({
    { "<leader>b",  group = "Buffer" },
    { "<leader>bd", ":bdelete<CR>",                    desc = "Close" },
    { "<leader>bc", ":BufferLinePickClose<CR>",        desc = "Pick Close" },
    { "<leader>bs", ":BufferLinePick<CR>",             desc = "Pick" },
    { "<leader>bl", ":BufferLineMoveNext<CR>",         desc = "Move right" },
    { "<leader>bh", ":BufferLineMovePrev<CR>",         desc = "Move left" },
    { "<leader>bq", ":BufferLineCloseLeft<CR>",        desc = "Close left" },
    { "<leader>bp", ":BufferLineCloseRight<CR>",       desc = "Close right " },
    { "<leader>b1", "<Cmd>BufferLineGoToBuffer 1<CR>", desc = "goto 1" },
    { "<leader>b2", "<Cmd>BufferLineGoToBuffer 2<CR>", desc = "goto 2" },
    { "<leader>b3", "<Cmd>BufferLineGoToBuffer 3<CR>", desc = "goto 3" },
    { "<leader>b4", "<Cmd>BufferLineGoToBuffer 4<CR>", desc = "goto 4" },
    { "<leader>b5", "<Cmd>BufferLineGoToBuffer 5<CR>", desc = "goto 5" },
    { "<leader>b6", "<Cmd>BufferLineGoToBuffer 6<CR>", desc = "goto 6" },
  }, opts)
end

pluginskeys.nvimtree = function()
  map("n", "<leader>e", ":NvimTreeToggle<CR>", opts)
end

pluginskeys.gitsigns = function(bufnr)
  local gsOpts = utils.merge_table(opts, { buffer = bufnr })

  wk.add({
    { "<leader>s",  group = "Gitsigns" },
    { "<leader>sj", "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", desc = "Next Hunk", },
    { "<leader>sk", "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", desc = "Prev Hunk", },
  }, utils.merge_table(gsOpts, { expr = true }))

  wk.add({
    { "<leader>s",  group = "Gitsigns" },
    { "<leader>ss", ":Gitsigns stage_hunk<CR>",                             desc = "Stage Hunk" },
    { "<leader>sr", ":Gitsigns reset_hunk<CR>",                             desc = "Reset Hunk" },
    { "<leader>sS", ":Gitsigns stage_buffer<CR>",                           desc = "Stage Buffer" },
    { "<leader>su", ":Gitsigns undo_stage_hunk<CR>",                        desc = "Undo Stage Hunk" },
    { "<leader>sR", "<cmd>Gitsigns reset_buffer<CR>",                       desc = "Reset Buffer" },
    { "<leader>sp", "<cmd>Gitsigns preview_hunk<CR>",                       desc = "Preview Hunk" },
    { "<leader>sb", '<cmd>lua require"gitsigns".blame_line{full=true}<CR>', desc = "Blame Line" },
    { "<leader>so", "<cmd>Gitsigns toggle_current_line_blame<CR>",          desc = "Toggle Current line Blame" },
    { "<leader>sd", "<cmd>Gitsigns diffthis<CR>",                           desc = "Diff This" },
    { "<leader>sD", '<cmd>lua require"gitsigns".diffthis("~")<CR>',         desc = "Diff This(~)" },
    { "<leader>sx", "<cmd>Gitsigns toggle_deleted<CR>",                     desc = "Toggle Deleted" },
  }, gsOpts)
end

pluginskeys.telescope = function()
  wk.add({
    { "<leader>f",  group = "File" },
    { "<leader>ff", "<cmd>Telescope find_files<cr>",  desc = "Find Files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>",   desc = "Find live_grep" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>",     desc = "Find Buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>",   desc = "Find help_tags" },
    { "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = "Find grep_tring" },
    { "<leader>fr", "<cmd>Telescope resume<cr>",      desc = "Find search history" },
  })
end

return pluginskeys
