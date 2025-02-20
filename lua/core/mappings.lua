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

pluginskeys.bufferline = function()
  map("n", "<TAB>", ":BufferLineCycleNext <CR>", opts)
  map("n", "<S-Tab>", ":BufferLineCyclePrev <CR>", opts)
  local wk = require("which-key")
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

pluginskeys.telescope = function()
  local wk = require("which-key")
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

pluginskeys.dap = function()
  local wk = require("which-key")
  wk.add({
    { "<leader>d",  group = "Dap" },
    { "<leader>dc", function() require("dap").continue() end,          desc = "Continue" },
    { "<leader>dr", function() require("dap").run_to_cursor() end,     desc = "Run to cursor" },
    { "<F8>",       function() require("dap").step_over() end,         desc = "Step over" },
    { "<F7>",       function() require("dap").step_into() end,         desc = "Step into" },
    { "<S-F8>",     function() require("dap").step_out() end,          desc = "Step out" },
    { "<leader>dv", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
    { "<leader>dt", function() require("dap").terminate() end,         desc = "Terminate" },
  })
end
pluginskeys.dapui = function()
  local wk = require("which-key")
  wk.add({
    { "<leader>d",  group = "Dap" },
    { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle debug ui" },
  })
end

pluginskeys.code_runner = function()
  local wk = require("which-key")
  wk.add({
    { "<leader>r",   group = "Code Runner" },
    { "<leader>rr",  ":RunCode<CR>",       desc = "run code" },
    { "<leader>rf",  ':RunFile<CR>',       desc = "run file" },
    { "<leader>rft", ':RunFile tab<CR>',   desc = "run file tab" },
    { "<leader>rp",  ':RunProject<CR>',    desc = "run project" },
    { "<leader>rc",  ':RunClose<CR>',      desc = "run close" },
  })
end

return pluginskeys
