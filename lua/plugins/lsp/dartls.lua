local lsp_utils = require("plugins.lsp.utils")

-- cmd/filetypes/root_markers 均使用 lspconfig 内置默认值
-- (lsp/dartls.lua)，如需覆盖再传入 vim.lsp.config

local M = {}

M.setup = function()
  -- dartls 随 Dart/Flutter SDK 提供，不走 mason
  if not lsp_utils.ensure_executable({
    cmd = "dart",
    filetypes = "dart",
    install = "安装 Flutter SDK 并将 flutter/bin 加入 PATH",
  }) then
    return
  end

  vim.lsp.enable('dartls')
end

return M
