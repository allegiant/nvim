-- cmd/filetypes/root_markers/init_options/settings 均使用 lspconfig 内置默认值
-- (lsp/dartls.lua)，如需覆盖再传入 vim.lsp.config

local M = {}

M.setup = function()
  -- dartls 随 Dart/Flutter SDK 提供，不走 mason
  if vim.fn.executable("dart") ~= 1 then
    return
  end

  vim.lsp.enable('dartls')
end

return M
