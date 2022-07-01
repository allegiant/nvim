local utils = require('core.utils')
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

pluginskeys.lspsaga = function()
  wk.register({
    ["g"] = {
      name = "+Lspsaga",
      f = { "<cmd>Lspsaga lsp_finder<CR>", "Definition Declaration", noremap = true, silent = true },
      a = { "<cmd>Lspsaga code_action<cr>", "Code Action", noremap = true, silent = true },
      h = { "<cmd>Lspsaga hover_doc<cr>", "Doc Hover", silent = true },
      s = { "<cmd>Lspsaga signature_help<CR>", "Signature help", noremap = true, silent = true },
      r = { "<cmd>Lspsaga rename<cr>", "Rename", noremap = true, silent = true },
      d = { "<cmd>Lspsaga preview_definition<CR>", "Preview definition", silent = true },
      o = { "<cmd>Lspsaga show_line_diagnostics<cr>", "Show line diagnostic", noremap = true, silent = true },
      j = { "<cmd>Lspsaga diagnostic_jump_next<cr>", "diagnostic next", noremap = true, silent = true },
      k = { "<cmd>Lspsaga diagnostic_jump_prev<cr>", "diagnostic prev", noremap = true, silent = true },
    },
  })

  wk.register({
    ["g"] = {
      name = "+Lspsaga",
      a = { ":<c-u>Lspsaga range_code_action<cr>", "Range Code Action" },
    }
  }, { mode = 'v' })
end

pluginskeys.lspconfig = function(mapbuf)
  -- wk.register({
  --   ["g"] = {
  --     name = "+Lsp",
  --     rn = { "<cmd>lua vim.lsp.buf.rename()<CR>", "Rename" },
  --     a = { "<cmd>lua vim.lsp.buf.code_action()<CR>", "Code Action" },
  --     h = { "<cmd>lua vim.lsp.buf.hover()<CR>", "Doc Hover" },
  --     d = { "<cmd>lua vim.lsp.buf.definition()<CR>", "Definition" },
  --     D = { "<cmd>lua vim.lsp.buf.declaration()<CR>", "Declaration" },
  --     i = { "<cmd>lua vim.lsp.buf.implementation()<CR>", "Implementation" },
  --     r = { "<cmd>lua vim.lsp.buf.references()<CR>", "References" },
  --     o = { "<cmd>lua vim.diagnostic.open_float()<CR>", "Show line diagnostic" },
  --     j = { "<cmd>lua vim.diagnostic.goto_next()<CR>", "diagnostic next" },
  --     k = { "<cmd>lua vim.diagnostic.goto_prev()<CR>", "diagnostic prev" },
  --   },
  -- },opts)

  wk.register {
    ["<leader>f"] = {
      name = "+file",
      m = { "<cmd>lua vim.lsp.buf.formatting()<CR>", "Lsp format" },
    },
  }
end

pluginskeys.bufferline = function()
  map("n", "<TAB>", ":BufferLineCycleNext <CR>", opts)
  map("n", "<S-Tab>", ":BufferLineCyclePrev <CR>", opts)
  wk.register({
    ["<leader>"] = {
      name = "Leader",
      ['1'] = { "<Cmd>BufferLineGoToBuffer 1<CR>", "goto 1" },
      ['2'] = { "<Cmd>BufferLineGoToBuffer 2<CR>", "goto 2" },
      ['3'] = { "<Cmd>BufferLineGoToBuffer 3<CR>", "goto 3" },
      ['4'] = { "<Cmd>BufferLineGoToBuffer 4<CR>", "goto 4" },
      ['5'] = { "<Cmd>BufferLineGoToBuffer 5<CR>", "goto 5" },
      ['6'] = { "<Cmd>BufferLineGoToBuffer 6<CR>", "goto 6" },
      ['7'] = { "<Cmd>BufferLineGoToBuffer 7<CR>", "goto 7" },
      ['8'] = { "<Cmd>BufferLineGoToBuffer 8<CR>", "goto 8" },
      ['9'] = { "<Cmd>BufferLineGoToBuffer 9<CR>", "goto 9" },
    },
  }, opts)

  wk.register({
    ["<leader>b"] = {
      name = "Buffer",
      d = { ":bdelete<CR>", "Close" },
      c = { ":BufferLinePickClose<CR>", "Pick Close" },
      s = { ":BufferLinePick<CR>", "Pick" },
      l = { ":BufferLineMoveNext<CR>", "Move right" },
      h = { ":BufferLineMovePrev<CR>", "Move left" },
      q = { ":BufferLineCloseLeft<CR>", "Close left" },
      p = { ":BufferLineCloseRight<CR>", "Close right " },
      ['1'] = { "<Cmd>BufferLineGoToBuffer 1<CR>", "goto 1" },
      ['2'] = { "<Cmd>BufferLineGoToBuffer 2<CR>", "goto 2" },
      ['3'] = { "<Cmd>BufferLineGoToBuffer 3<CR>", "goto 3" },
      ['4'] = { "<Cmd>BufferLineGoToBuffer 4<CR>", "goto 4" },
      ['5'] = { "<Cmd>BufferLineGoToBuffer 5<CR>", "goto 5" },
      ['6'] = { "<Cmd>BufferLineGoToBuffer 6<CR>", "goto 6" },
    },
  }, opts)
end

pluginskeys.barbar = function()
  map("n", "<TAB>", ":BufferNext<CR>", opts)
  map("n", "<S-Tab>", ":BufferPrevious<CR>", opts)

  map('n', '<A-1>', ':BufferGoto 1<CR>', opts)
  map('n', '<A-2>', ':BufferGoto 2<CR>', opts)
  map('n', '<A-3>', ':BufferGoto 3<CR>', opts)
  map('n', '<A-4>', ':BufferGoto 4<CR>', opts)
  map('n', '<A-5>', ':BufferGoto 5<CR>', opts)
  map('n', '<A-6>', ':BufferGoto 6<CR>', opts)
  map('n', '<A-7>', ':BufferGoto 7<CR>', opts)
  map('n', '<A-8>', ':BufferGoto 8<CR>', opts)
  map('n', '<A-9>', ':BufferGoto 9<CR>', opts)
  map('n', '<A-0>', ':BufferLast<CR>', opts)

  wk.register({
    ["<leader>b"] = {
      name = "Buffer",
      l = { ':BufferMoveNext<CR>', "Move right" },
      h = { ':BufferMovePrevious<CR>', "Move left" },
      p = { ':BufferPin<CR>', "Pin/unpin" },
      c = { ':BufferClose<CR>', "Close" },
      s = { ':BufferPick<CR>', "Picking mode" },
    }
  }, opts)
end

pluginskeys.nvimtree = function()
  map("n", "<leader>e", ":NvimTreeToggle<CR>", opts)
end

pluginskeys.gitsigns = function(bufnr)
  local gsOpts = utils.merge_table(opts, { buffer = bufnr })

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
  }, utils.merge_table(gsOpts, { expr = true }))

  wk.register({
    ["<leader>s"] = {
      s = { ":Gitsigns stage_hunk<CR>", "Stage Hunk" },
      r = { ":Gitsigns reset_hunk<CR>", "Reset Hunk" },
      S = { ":Gitsigns stage_buffer<CR>", "Stage Buffer" },
      u = { ":Gitsigns undo_stage_hunk<CR>", "Undo Stage Hunk" },
      R = { "<cmd>Gitsigns reset_buffer<CR>", "Reset Buffer" },
      p = { "<cmd>Gitsigns preview_hunk<CR>", "Preview Hunk" },
      b = { '<cmd>lua require"gitsigns".blame_line{full=true}<CR>', "Blame Line" },
      o = { "<cmd>Gitsigns toggle_current_line_blame<CR>", "Toggle Current line Blame" },
      d = { "<cmd>Gitsigns diffthis<CR>", "Diff This" },
      D = { '<cmd>lua require"gitsigns".diffthis("~")<CR>', "Diff This(~)" },
      x = { "<cmd>Gitsigns toggle_deleted<CR>", "Toggle Deleted" },
    },
  }, gsOpts)
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

pluginskeys.autopairs = function()
  local keymaps = {
    map = '<C-G>' -- fast wrap
  }
  return keymaps;
end

return pluginskeys
