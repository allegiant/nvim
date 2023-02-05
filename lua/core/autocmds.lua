local autocmd = vim.api.nvim_create_autocmd
autocmd({ "BufLeave" }, { pattern = { "*" }, command = "if &buftype == 'quickfix'|q|endif" })

vim.cmd [[autocmd VimEnter * setlocal formatoptions-=c formatoptions-=r formatoptions-=o]]
vim.cmd [[autocmd BufEnter *slint setlocal filetype=slint]]
