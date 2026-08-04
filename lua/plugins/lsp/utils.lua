local M = {}

--- 检查 LSP server 的可执行文件是否存在。
--- 存在返回 true；缺失时注册一个 FileType 一次性提醒（打开对应文件才提示，
--- 每次会话最多一次）并返回 false。
---@param opts { cmd: string, filetypes: string|string[], install: string }
---@return boolean
M.ensure_executable = function(opts)
  if vim.fn.executable(opts.cmd) == 1 then
    return true
  end

  vim.api.nvim_create_autocmd("FileType", {
    pattern = opts.filetypes,
    once = true,
    callback = function()
      vim.notify(
        ("LSP 不可用: %s 未安装\n安装方式: %s"):format(opts.cmd, opts.install),
        vim.log.levels.WARN
      )
    end,
    desc = "Notify missing LSP server: " .. opts.cmd,
  })
  return false
end

return M
