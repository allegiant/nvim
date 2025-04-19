local utils = require "core.utils"
---@diagnostic disable-next-line: undefined-global
local vim = vim

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
-- split windows
map("n", "<leader>sv", ":vsp<CR>", opts)
map("n", "<leader>sh", ":sp<CR>", opts)

map("n", "<leader>nl", ":nohlsearch<CR>", opts)

local pluginskeys = {}

pluginskeys.lspsaga = function()
  local wk = require("which-key")
  wk.add({
    { "g",  group = "Lspsaga" },
    { "gf", "<cmd>Lspsaga finder<CR>",                desc = "Ref + Impl" },
    { "ga", "<cmd>Lspsaga code_action<CR>",           desc = "Code Action",           mode = { "n", "v" } },
    { "gr", "<cmd>Lspsaga rename<CR>",                desc = "Rename",                silent = true },
    { "gd", "<cmd>Lspsaga goto_definition<CR>",       desc = "goto definition" },
    { "gt", "<cmd>Lspsaga goto_type_definition<CR>",  desc = "goto type definition" },
    { "go", "<cmd>Lspsaga show_line_diagnostics<cr>", desc = "Show line diagnostic" },
    { "gj", "<cmd>Lspsaga diagnostic_jump_next<cr>",  desc = "diagnostic next" },
    { "gk", "<cmd>Lspsaga diagnostic_jump_prev<cr>",  desc = "diagnostic prev" },
    { "gh", "<cmd>Lspsaga hover_doc<CR>",             desc = "Doc Hover" },
    { "gi", "<cmd>Lspsaga incoming_calls<CR>",        desc = "incoming calls" },
    { "gu", "<cmd>Lspsaga outgoing_calls<CR>",        desc = "outgoing calls" },
    { "gs", "<cmd>Lspsaga outline<CR>",               desc = "outline code structure" },
  })
end

pluginskeys.gitsigns = function(bufnr, gitsigns)
  local gsOpts = utils.merge_table(opts, { buffer = bufnr })

  local wk = require("which-key")

  function nav_next_hunk()
    if vim.wo.diff then
      vim.cmd.normal({ ']c', bang = true })
    else
      gitsigns.nav_hunk('next')
    end
  end

  function nav_prev_hunk()
    if vim.wo.diff then
      vim.cmd.normal({ '[c', bang = true })
    else
      gitsigns.nav_hunk('prev')
    end
  end

  wk.add({
    { "<leader>s",  group = "Gitsigns" },
    { "<leader>sj", '<cmd>lua nav_next_hunk()<CR>', desc = "Next Hunk", },
    { "<leader>sk", '<cmd>lua nav_prev_hunk()<CR>', desc = "Prev Hunk", },
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

return pluginskeys
