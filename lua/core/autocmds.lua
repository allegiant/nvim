local autocmd = vim.api.nvim_create_autocmd
autocmd({ "BufLeave" }, { pattern = { "*" }, command = "if &buftype == 'quickfix'|q|endif" })

vim.cmd [[autocmd VimEnter * setlocal formatoptions-=c formatoptions-=r formatoptions-=o]]
vim.cmd [[autocmd BufEnter *slint setlocal filetype=slint]]
-- 打开文件时恢复上一次光标所在位置
vim.cmd [[ autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") |	 exe "normal! g`\"" | endif ]]
