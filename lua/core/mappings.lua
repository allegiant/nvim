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
return pluginskeys
