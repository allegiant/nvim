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

wk.register {
  ["sv"] = { ":vsp<CR>", "vertical split" },
  ["sh"] = { ":sp<CR>", "Horizontal split" },
}
local pluginskeys = {}




pluginskeys.bufferline = function()
  map("n", "<TAB>", ":BufferLineCycleNext <CR>", { noremap = true, silent = true })
  map("n", "<S-Tab>", ":BufferLineCyclePrev <CR>", { noremap = true, silent = true })
  wk.register({
    ["<leader>b"] = {
      name = "Buffer",
      c = { ":BufferLinePickClose<CR>", "Pick Close" },
      s = { ":BufferLinePick<CR>", "Pick" },
      l = { ":BufferLineMoveNext<CR>", "Move next" },
      h = { ":BufferLineMovePrev<CR>", "Move Prev" },
      q = { ":BufferLineCloseLeft<CR>", "Close left" },
      p = { ":BufferLineCloseRight<CR>", "Move right " },
    },
  }, opts)
end

pluginskeys.nvimtree = function()
  map("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
end

pluginskeys.gitsigns = function(bufnr)
  local gsOpts = vim.tbl_extend("force", { buffer = bufnr }, opts)
  local ngsOpts = vim.tbl_extend("force", { mode = "n" }, gsOpts)
  local exprgsOpts = vim.tbl_extend("force", { expr = true }, ngsOpts)

  wk.register({
    ["<leader>s"] = {
      name = "Gitsigns",
      j = {
        "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'",
        "Next Hunk",
      },
      k = {
        "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'",
        "Prev Hunk",
      },
    },
  }, exprgsOpts)
  wk.register {
    ["<leader>s"] = {
      s = { ":Gitsigns stage_hunk<CR>", "Stage Hunk", unpack(ngsOpts) },
      r = { ":Gitsigns reset_hunk<CR>", "Reset Hunk", unpack(ngsOpts) },
      S = { ":Gitsigns stage_buffer<CR>", "Stage Buffer", unpack(ngsOpts) },
      u = { ":Gitsigns undo_stage_hunk<CR>", "Undo Stage Hunk", unpack(ngsOpts) },
      R = { "<cmd>Gitsigns reset_buffer<CR>", "Reset Buffer", unpack(ngsOpts) },
      p = { "<cmd>Gitsigns preview_hunk<CR>", "Preview Hunk", unpack(ngsOpts) },
      b = { '<cmd>lua require"gitsigns".blame_line{full=true}<CR>', "Blame Line", unpack(ngsOpts) },
      o = { "<cmd>Gitsigns toggle_current_line_blame<CR>", "Toggle Current line Blame", unpack(ngsOpts) },
      d = { "<cmd>Gitsigns diffthis<CR>", "Diff This", unpack(ngsOpts) },
      D = { '<cmd>lua require"gitsigns".diffthis("~")<CR>', "Diff This(~)", unpack(ngsOpts) },
      x = { "<cmd>Gitsigns toggle_deleted<CR>", "Toggle Deleted", unpack(ngsOpts) },
    },
  }
end

pluginskeys.telescope = function()
  wk.register {
    ["<leader>f"] = {
      name = "+file",
      f = { "<cmd>Telescope find_files<cr>", "Find Files" },
      g = { "<cmd>Telescope live_grep<cr>", "Find live_grep" },
      b = { "<cmd>Telescope buffers<cr>", "Find Buffers" },
      h = { "<cmd>Telescope help_tags<cr>", "Find help_tags" },
      w = { "<cmd>Telescope grep_string<cr>", "Find grep_tring" },
    },
  }
end

return pluginskeys
