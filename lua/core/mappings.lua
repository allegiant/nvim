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

-- equalize window sizes
map("n", "eq", "<C-w>=", opts)


wk.register {
    ["sv"] = { ":vsp<CR>", "vertical split" },
    ["sh"] = { ":sp<CR>", "Horizontal split" },
}
local pluginskeys = {}

pluginskeys.lspsaga = function()
  local keymap = vim.keymap.set
  keymap("n", "gf", "<cmd>Lspsaga lsp_finder<CR>")
  keymap({ "n", "v" }, "ga", "<cmd>Lspsaga code_action<CR>")
  keymap("n", "gr", "<cmd>Lspsaga rename<CR>")
  keymap("n", "gr", "<cmd>Lspsaga rename ++project<CR>")
  keymap("n", "gd", "<cmd>Lspsaga peek_definition<CR>")
  keymap("n", "gd", "<cmd>Lspsaga goto_definition<CR>")
  keymap("n", "go", "<cmd>Lspsaga show_line_diagnostics<CR>")
  keymap("n", "gc", "<cmd>Lspsaga show_cursor_diagnostics<CR>")
  keymap("n", "<leader>gb", "<cmd>Lspsaga show_buf_diagnostics<CR>")
  keymap("n", "gj", "<cmd>Lspsaga diagnostic_jump_next<CR>")
  keymap("n", "gk", "<cmd>Lspsaga diagnostic_jump_prev<CR>")
  keymap("n", "[e", function()
    require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
  end)
  keymap("n", "]e", function()
    require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
  end)
  keymap("n", "<leader>o", "<cmd>Lspsaga outline<CR>")
  keymap("n", "gh", "<cmd>Lspsaga hover_doc<CR>")
  keymap("n", "gK", "<cmd>Lspsaga hover_doc ++keep<CR>")
  keymap("n", "<Leader>ci", "<cmd>Lspsaga incoming_calls<CR>")
  keymap("n", "<Leader>co", "<cmd>Lspsaga outgoing_calls<CR>")

  -- wk.register {
  --     ["g"] = {
  --         name = "+Lspsaga",
  --         f = { "<cmd>Lspsaga lsp_finder<CR>", "Definition Declaration", silent = true },
  --         a = { "<cmd>Lspsaga code_action<CR>", "Code Action", silent = true },
  --         r = { "<cmd>Lspsaga rename<CR>", "Rename", silent = true },
  --         d = { "<cmd>Lspsaga peek_definition<CR>", "Preview definition", silent = true },
  --         o = { "<cmd>Lspsaga show_line_diagnostics<cr>", "Show line diagnostic", silent = true },
  --         s = { "<cmd>Lspsaga show_cursor_diagnostics<CR>", "Show cursor diagnostic", silent = true },
  --         j = { "<cmd>Lspsaga diagnostic_jump_next<cr>", "diagnostic next", silent = true },
  --         k = { "<cmd>Lspsaga diagnostic_jump_prev<cr>", "diagnostic prev", silent = true },
  --         h = { "<cmd>Lspsaga hover_doc<CR>", "Doc Hover", silent = true },
  --     },
  -- }
  --
  -- wk.register({
  --     ["g"] = {
  --         name = "+Lspsaga",
  --         a = { ":<c-u>Lspsaga range_code_action<cr>", "Range Code Action" },
  --     },
  -- }, { mode = "v" })
  --
  -- wk.register({
  --     ["<leader>"] = {
  --         name = "+outline",
  --         o = { "<cmd>LSoutlineToggle<CR>", "outline Toggle", silent = true },
  --     },
  -- })
end

pluginskeys.lspconfig = function(bufnr)
  local bufOpts = { noremap = true, silent = true, buffer = bufnr }
  wk.register({
      ["g"] = {
          name = "+Lsp",
          o = { "<cmd>lua vim.diagnostic.open_float()<CR>", "Show line diagnostic" },
          j = { "<cmd>lua vim.diagnostic.goto_next()<CR>", "diagnostic next" },
          k = { "<cmd>lua vim.diagnostic.goto_prev()<CR>", "diagnostic prev" },
          q = { "<cmd>lua vim.diagnostic.setloclist()<CR>", "diagnostic setloclist" },
      },
  }, opts)

  wk.register({
      ["g"] = {
          name = "+Lsp",
          d = { "<cmd>lua vim.lsp.buf.definition()<CR>", "Definition" },
          D = { "<cmd>lua vim.lsp.buf.declaration()<CR>", "Declaration" },
          h = { "<cmd>lua vim.lsp.buf.hover()<CR>", "Doc Hover" },
          i = { "<cmd>lua vim.lsp.buf.implementation()<CR>", "Implementation" },
          s = { "<cmd>vim.lsp.buf.signature_help()<CR>", "Signature help" },
          r = { "<cmd>lua vim.lsp.buf.rename()<CR>", "Rename" },
          a = { "<cmd>lua vim.lsp.buf.code_action()<CR>", "Code Action" },
          f = { "<cmd>lua vim.lsp.buf.references()<CR>", "References" },
      },
  }, bufOpts)

  wk.register({
      ["<leader>f"] = {
          name = "+file",
          m = { function() vim.lsp.buf.format { async = true } end, "Lsp format" },
      },
  }, { buffer = bufnr, silent = true, noremap = true })
end

pluginskeys.bufferline = function()
  map("n", "<TAB>", ":BufferLineCycleNext <CR>", opts)
  map("n", "<S-Tab>", ":BufferLineCyclePrev <CR>", opts)
  wk.register({
      ["<leader>"] = {
          name = "Leader",
          ["1"] = { "<Cmd>BufferLineGoToBuffer 1<CR>", "goto 1" },
          ["2"] = { "<Cmd>BufferLineGoToBuffer 2<CR>", "goto 2" },
          ["3"] = { "<Cmd>BufferLineGoToBuffer 3<CR>", "goto 3" },
          ["4"] = { "<Cmd>BufferLineGoToBuffer 4<CR>", "goto 4" },
          ["5"] = { "<Cmd>BufferLineGoToBuffer 5<CR>", "goto 5" },
          ["6"] = { "<Cmd>BufferLineGoToBuffer 6<CR>", "goto 6" },
          ["7"] = { "<Cmd>BufferLineGoToBuffer 7<CR>", "goto 7" },
          ["8"] = { "<Cmd>BufferLineGoToBuffer 8<CR>", "goto 8" },
          ["9"] = { "<Cmd>BufferLineGoToBuffer 9<CR>", "goto 9" },
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
          ["1"] = { "<Cmd>BufferLineGoToBuffer 1<CR>", "goto 1" },
          ["2"] = { "<Cmd>BufferLineGoToBuffer 2<CR>", "goto 2" },
          ["3"] = { "<Cmd>BufferLineGoToBuffer 3<CR>", "goto 3" },
          ["4"] = { "<Cmd>BufferLineGoToBuffer 4<CR>", "goto 4" },
          ["5"] = { "<Cmd>BufferLineGoToBuffer 5<CR>", "goto 5" },
          ["6"] = { "<Cmd>BufferLineGoToBuffer 6<CR>", "goto 6" },
      },
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
          r = { "<cmd>Telescope resume<cr>", "Find search history" },
      },
  }
end

return pluginskeys
