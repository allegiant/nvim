local vim = vim

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

local pluginskeys = {}

pluginskeys.lsp = function(mapbuf)
   mapbuf("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
   -- code action
   mapbuf("n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)

   -- go xx
   mapbuf("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
   mapbuf("n", "gh", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
   mapbuf("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
   mapbuf("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
   mapbuf("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
   -- diagnostic
   mapbuf("n", "go", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
   mapbuf("n", "gp", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
   mapbuf("n", "gn", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
   -- mapbuf('n', '<leader>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opt)
   mapbuf("n", "<gk>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
   -- leader + =
   mapbuf("n", "<leader>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
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
   map("n", "<leader>1", "<Cmd>BufferLineGoToBuffer 1<CR>", opts)
   map("n", "<leader>2", "<Cmd>BufferLineGoToBuffer 2<CR>", opts)
   map("n", "<leader>3", "<Cmd>BufferLineGoToBuffer 3<CR>", opts)
   map("n", "<leader>4", "<Cmd>BufferLineGoToBuffer 4<CR>", opts)
   map("n", "<leader>5", "<Cmd>BufferLineGoToBuffer 5<CR>", opts)
   map("n", "<leader>6", "<Cmd>BufferLineGoToBuffer 6<CR>", opts)
   map("n", "<leader>7", "<Cmd>BufferLineGoToBuffer 7<CR>", opts)
   map("n", "<leader>8", "<Cmd>BufferLineGoToBuffer 8<CR>", opts)
   map("n", "<leader>9", "<Cmd>BufferLineGoToBuffer 9<CR>", opts)
end

pluginskeys.nvimtree = function()
   map("n", "<leader>e", ":NvimTreeToggle<CR>", opts)
end

return pluginskeys
