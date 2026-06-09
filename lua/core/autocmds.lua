local autocmd = vim.api.nvim_create_autocmd
local ui_group = vim.api.nvim_create_augroup("user_ui_highlights", { clear = true })

local function set_ui_highlights()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
  local background = normal.bg and string.format("#%06x", normal.bg) or "#fbf1c7"

  vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#d8cfa3", bg = "NONE" })
  vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = background, bg = "NONE" })
end

set_ui_highlights()
autocmd("ColorScheme", {
  group = ui_group,
  callback = set_ui_highlights,
})

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

autocmd({ 'VimLeavePre' }, {
  group = vim.api.nvim_create_augroup('fuck_shada_temp', { clear = true }),
  pattern = { '*' },
  callback = function()
    local status = 0
    for _, f in ipairs(vim.fn.globpath(vim.fn.stdpath('data') .. '/shada', '*tmp*', false, true)) do
      if vim.tbl_isempty(vim.fn.readfile(f)) then
        status = status + vim.fn.delete(f)
      end
    end
    if status ~= 0 then
      vim.notify('Could not delete empty temporary ShaDa files.', vim.log.levels.ERROR)
      vim.fn.getchar()
    end
  end,
  desc = "Delete empty temp ShaDa files"
})
