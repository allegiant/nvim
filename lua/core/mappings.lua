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
  wk.register {
    ["g"] = {
      name = "+Lspsaga",
      r = { "<cmd>Lspsaga rename<cr>", "Rename" },
      a = { "<cmd>Lspsaga code_action<cr>", "Code Action" },
      h = { "<cmd>Lspsaga hover_doc<cr>", "Doc Hover" },
      d = { "<cmd>Lspsaga lsp_finder<CR>", "Definition Declaration" },
      o = { "<cmd>Lspsaga show_line_diagnostics<cr>", "Show line diagnostic" },
      j = { "<cmd>Lspsaga diagnostic_jump_next<cr>", "diagnostic next" },
      k = { "<cmd>Lspsaga diagnostic_jump_prev<cr>", "diagnostic prev" },
    },
    ["<C-u"] = { "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1, '<c-u>')<cr>", "Doc scroll up" },
    ["<C-d"] = { "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1, '<c-d>')<cr>", "Doc scroll down" },
  }
end

pluginskeys.lsp = function(mapbuf)
  wk.register {
    ["<leader>l"] = { "<cmd>lua vim.lsp.buf.formatting()<CR>", "Lsp format" },
  }
  --mapbuf("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
  -- code action
  --mapbuf("n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)

  -- go xx
  -- mapbuf("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
  --mapbuf("n", "gh", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
  --mapbuf("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
  -- mapbuf("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
  --mapbuf("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
  -- diagnostic
  -- mapbuf("n", "go", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
  --mapbuf("n", "gp", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
  --mapbuf("n", "gn", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
  -- mapbuf('n', '<leader>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opt)
  --mapbuf("n", "<gk>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
  -- leader + =
  --mapbuf("n", "<leader>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
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

pluginskeys.bufdelete = function()
  wk.register({
    ["<leader>b"] = {
      name = "Buffer",
      d = { ":Bdelete<CR>", "Delete From List" },
      w = { ":Bwipeout<CR>", "Delete" },
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
