local autocmd = vim.api.nvim_create_autocmd
autocmd({ "BufLeave" }, { pattern = { "*" }, command = "if &buftype == 'quickfix'|q|endif" })

-- requires install xsel
if vim.fn.has('wsl') == 1 then
    vim.api.nvim_create_autocmd('TextYankPost', {
        group = vim.api.nvim_create_augroup('Yank', { clear = true }),
        callback = function()
            vim.fn.system('clip.exe', vim.fn.getreg('"'))
        end,
    })
end

vim.cmd [[autocmd VimEnter * setlocal formatoptions-=c formatoptions-=r formatoptions-=o]]
