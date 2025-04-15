local autocmd = vim.api.nvim_create_autocmd
autocmd({ "BufLeave" }, { pattern = { "*" }, command = "if &buftype == 'quickfix'|q|endif" })
-- 去除自动换行注释
autocmd({ "VimEnter" }, { pattern = { "*" }, command = "setlocal formatoptions-=c formatoptions-=r formatoptions-=o" })
-- 打开文件时恢复上一次光标所在位置
vim.cmd [[ autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") |	 exe "normal! g`\"" | endif ]]
-- 自动保存
-- autocmd({ "InsertLeave" }, { pattern = { "*" }, command = "silent! wall", nested = true, })
-- set indent to 2 for lua
autocmd("FileType", {
  pattern = "lua",
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
  end,
})

autocmd("FileType", {
  pattern = "slint",
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
  end,
})

autocmd("FileType", {
  pattern = "dart",
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    -- vim.opt_local.softtabstop = 4
    -- vim.opt_local.smarttab = true
    -- vim.opt_local.expandtab = true
  end,
})
