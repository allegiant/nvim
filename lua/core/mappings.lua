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
      r = { "<cmd>Lspsaga rename<cr>", "Rename" },
      a = { "<cmd>Lspsaga code_action<cr>", "Code Action", mode = 'n' },
      h = { "<cmd>Lspsaga hover_doc<cr>", "Doc Hover" },
      f = { "<cmd>Lspsaga lsp_finder<CR>", "Definition Declaration" },
      o = { "<cmd>Lspsaga show_line_diagnostics<cr>", "Show line diagnostic" },
      j = { "<cmd>Lspsaga diagnostic_jump_next<cr>", "diagnostic next" },
      k = { "<cmd>Lspsaga diagnostic_jump_prev<cr>", "diagnostic prev" },
      s = { "<cmd>lua require('lspsaga.signaturehelp').signature_help()<CR>", "Signature help" },
      d = { "<cmd>lua require'lspsaga.provider'.preview_definition()<CR>", "Preview definition" },
    },
    ["<C-u"] = { "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1, '<c-u>')<cr>", "Doc scroll up" },
    ["<C-d"] = { "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1, '<c-d>')<cr>", "Doc scroll down" },
  }, { mode = 'n' })

  wk.register({
    ["g"] = {
      name = "+Lspsaga",
      a = { ":<c-u>Lspsaga range_code_action<cr>", "Range Code Action" },
    }
  }, { mode = 'v' })
end

pluginskeys.lsp = function(mapbuf)
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

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
end

local feedkey = function(key, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

pluginskeys.cmp = function(cmp)
  return {
    ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
    ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
    ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
    ["<C-y>"] = cmp.config.disable,
    ["<C-e>"] = cmp.mapping {
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    },
    ["<CR>"] = cmp.mapping.confirm { select = true },
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif vim.fn["vsnip#available"](1) == 1 then
        feedkey("<Plug>(vsnip-expand-or-jump)", "")
      elseif has_words_before() then
        cmp.complete()
      else
        fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_prev_item()
      elseif vim.fn["vsnip#jumpable"](-1) == 1 then
        feedkey("<Plug>(vsnip-jump-prev)", "")
      end
    end, { "i", "s" }),
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

pluginskeys.autopairs = function()
  local keymaps = {
    map = '<C-G>' -- fast wrap
  }
  return keymaps;
end

return pluginskeys
