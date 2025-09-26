local opts = {
  cmd = { "sqls", "-config", vim.loop.cwd() .. "/.sqlsrc.yml" },
  filetypes = { "sql", "mysql" },
  root_markers = { "config.yml", ".sqlsrc.yml" }
}

local M = {}

M.setup = function()
  local present, mason_registry = pcall(require, "mason-registry")
  if not present then
    return
  end

  local installed = mason_registry.is_installed("sqls")
  if not installed then
    return
  end



  vim.lsp.config('sqls', opts)
  vim.lsp.enable('sqls')
end

return M
