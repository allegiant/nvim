local vscode = require("vscode")
local whichkey = {
  show = function()
    vim.fn.VSCodeNotify("whichkey.show")
  end,
}

local fold = {
  toggle = function()
    vim.fn.VSCodeNotify("editor.toggleFold")
  end,

  all = function()
    vim.fn.VSCodeNotify("editor.foldAll")
  end,
  openAll = function()
    vim.fn.VSCodeNotify("editor.unfoldAll")
  end,

  close = function()
    vim.fn.VSCodeNotify("editor.fold")
  end,
  open = function()
    vim.fn.VSCodeNotify("editor.unfold")
  end,
  openRecursive = function()
    vim.fn.VSCodeNotify("editor.unfoldRecursively")
  end,

  blockComment = function()
    vim.fn.VSCodeNotify("editor.foldAllBlockComments")
  end,

  allMarkerRegion = function()
    vim.fn.VSCodeNotify("editor.foldAllMarkerRegions")
  end,
  openAllMarkerRegion = function()
    vim.fn.VSCodeNotify("editor.unfoldAllMarkerRegions")
  end,
}

-- remap leader key
vim.keymap.set({ "n" }, "<Space>", "")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set({ "v" }, "<leader>y", '"+y')
vim.keymap.set({ "n" }, "<leader>y", '"+y')
vim.keymap.set({ "n" }, "<leader>Y", '"+yg_')
vim.keymap.set({ "n" }, "<leader>p", '"+p')
vim.keymap.set({ "n" }, "<leader>P", '"+P')
vim.keymap.set({ "v" }, "<leader>p", '"+p')
vim.keymap.set({ "v" }, "<leader>P", '"+P')
vim.keymap.set({ "v" }, "<leader>d", '"+d')


-- -- vim.keymap.set({ "n", "v" }, "<leader>", whichkey.show)
vim.keymap.set(
  { "n", "v" },
  "<Space>",
  "<cmd>lua require('vscode').action('whichkey.show')<CR>",
  { noremap = true, silent = true, desc = "WhichKey Show" }
)

-- code action
vim.keymap.set({ "n" }, "ga", "<cmd>lua require('vscode').action('editor.action.codeAction')<CR>")
vim.keymap.set({ "n" }, "gA", "<cmd>lua require('vscode').action('editor.action.sourceAction')<CR>")
vim.keymap.set({ "n" }, "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
vim.keymap.set({ "n" }, "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
vim.keymap.set({ "n" }, "gf", "<cmd>lua vim.lsp.buf.references()<CR>")
vim.keymap.set({ "n" }, "gr", "<cmd>lua vim.lsp.buf.rename()<CR>")
vim.keymap.set({ "n" }, "gR", "<cmd>lua require('vscode').action('editor.action.Refactor')<CR>")
vim.keymap.set({ "n" }, "gj", "<cmd>lua require('vscode').action('editor.action.marker.next')<CR>")
vim.keymap.set({ "n" }, "gk", "<cmd>lua require('vscode').action('editor.action.marker.prev')<CR>")
vim.keymap.set({ "n" }, "gh", "<cmd>lua vim.lsp.buf.hover()<CR>")
vim.keymap.set({ "n" }, "<leader>fm", "<cmd>lua vim.lsp.buf.format()<CR>")
vim.keymap.set({ "n" }, "<leader>e", "<cmd>lua require('vscode').action('workbench.action.toggleSidebarVisibility')<CR>")

--folding
vim.keymap.set({ "n" }, "zr", fold.openAll)
vim.keymap.set({ "n" }, "zO", fold.openRecursive)
vim.keymap.set({ "n" }, "zo", fold.open)
vim.keymap.set({ "n" }, "zm", fold.all)
vim.keymap.set({ "n" }, "zb", fold.blockComment)
vim.keymap.set({ "n" }, "zc", fold.close)
vim.keymap.set({ "n" }, "zg", fold.allMarkerRegion)
vim.keymap.set({ "n" }, "zG", fold.openAllMarkerRegion)
vim.keymap.set({ "n" }, "za", fold.toggle)
