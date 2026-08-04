local lsp_utils = require("plugins.lsp.utils")

-- cmd/filetypes/root_markers 均使用 lspconfig 内置默认值
-- (lsp/rust_analyzer.lua，自带 workspace reload 与 sysroot 探测)

local M = {}

M.setup = function()
  -- rust-analyzer 由 rustup 提供，不走 mason
  if not lsp_utils.ensure_executable({
    cmd = "rust-analyzer",
    filetypes = "rust",
    install = "rustup component add rust-analyzer",
  }) then
    return
  end

  vim.lsp.enable('rust_analyzer')
end

return M
