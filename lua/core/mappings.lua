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

pluginskeys.lsp = function(mapbuf)
  wk.register {
    ["<leader>rn"] = { "<cmd>lua vim.lsp.buf.rename()<CR>", "Lsp Rename" },
    ["<leader>ca"] = { "<cmd>lua vim.lsp.buf.code_action()<CR>", "Lsp Code Action" },
    ["gd"] = { "<cmd>lua vim.lsp.buf.definition()<CR>", "Lsp Go to definition" },
    ["gh"] = { "<cmd>lua vim.lsp.buf.hover()<CR>", "Lsp Show Hover" },
    ["gD"] = { "<cmd>lua vim.lsp.buf.declaration()<CR>", "Lsp Go To Declaration" },
    ["gi"] = { "<cmd>lua vim.lsp.buf.implementation()<CR>", "Lsp Go To Implementation" },
    ["gr"] = { "<cmd>lua vim.lsp.buf.references()<CR>", "Lsp Go To references" },
    ["go"] = { "<cmd>lua vim.diagnostic.open_float()<CR>", "diagnostic open float" },
    ["gp"] = { "<cmd>lua vim.diagnostic.goto_prev()<CR>", "diagnostic goto prev" },
    ["gn"] = { "<cmd>lua vim.diagnostic.goto_next()<CR>", "diagnostic goto next" },
    ["gk"] = { "<cmd>lua vim.lsp.buf.signature_help()<CR>", "Lsp signature help" },
    ["<leader>f"] = { "<cmd>lua vim.lsp.buf.formatting()<CR>", "Lsp format" },
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
  wk.register {
    ["<leader>c"] = { ":BufferLinePickClose<CR>", "Buffer Close" },
    ["<leader>p"] = { ":BufferLinePick<CR>", "Buffer Pick" },
  }
  map("n", "<TAB>", ":BufferLineCycleNext <CR>", opts)
  map("n", "<S-Tab>", ":BufferLineCyclePrev <CR>", opts)
end

pluginskeys.nvimtree = function()
  map("n", "<leader>e", ":NvimTreeToggle<CR>", opts)
end

pluginskeys.gitsigns = function(bufnr)
  local function gsmap(mode, lhs, rhs, opts)
    opts = vim.tbl_extend("force", { noremap = true, silent = true }, opts or {})
    vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
  end
  -- Navigation
  gsmap("n", "]c", "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", { expr = true })
  gsmap("n", "[c", "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", { expr = true })

  -- Actions
  gsmap("n", "<leader>hs", ":Gitsigns stage_hunk<CR>")
  gsmap("v", "<leader>hs", ":Gitsigns stage_hunk<CR>")
  gsmap("n", "<leader>hr", ":Gitsigns reset_hunk<CR>")
  gsmap("v", "<leader>hr", ":Gitsigns reset_hunk<CR>")
  gsmap("n", "<leader>hS", "<cmd>Gitsigns stage_buffer<CR>")
  gsmap("n", "<leader>hu", "<cmd>Gitsigns undo_stage_hunk<CR>")
  gsmap("n", "<leader>hR", "<cmd>Gitsigns reset_buffer<CR>")
  gsmap("n", "<leader>hp", "<cmd>Gitsigns preview_hunk<CR>")
  gsmap("n", "<leader>hb", '<cmd>lua require"gitsigns".blame_line{full=true}<CR>')
  gsmap("n", "<leader>tb", "<cmd>Gitsigns toggle_current_line_blame<CR>")
  gsmap("n", "<leader>hd", "<cmd>Gitsigns diffthis<CR>")
  gsmap("n", "<leader>hD", '<cmd>lua require"gitsigns".diffthis("~")<CR>')
  gsmap("n", "<leader>td", "<cmd>Gitsigns toggle_deleted<CR>")

  -- Text object
  gsmap("o", "ih", ":<C-U>Gitsigns select_hunk<CR>")
  gsmap("x", "ih", ":<C-U>Gitsigns select_hunk<CR>")
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
  --map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", opts)
  --map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", opts)
  --map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", opts)
  --map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", opts)
  --map("n", "<leader>fw", "<cmd>Telescope grep_string<cr>", opts)
end

return pluginskeys
