local lsp_utils = require("plugins.lsp.utils")

-- cmd/filetypes/init_options/root_markers 均使用 lspconfig 内置默认值
-- (lsp/jsonls.lua)；默认 cmd 会优先使用项目 node_modules/.bin 下的 server
-- snippetSupport 由 blink.cmp 统一注入，无需手动覆盖 capabilities

local M = {}

M.setup = function()
  if not lsp_utils.ensure_executable({
    cmd = "vscode-json-language-server",
    filetypes = { "json", "jsonc" },
    install = ":MasonInstall json-lsp",
  }) then
    return
  end

  vim.lsp.enable('jsonls')
end

return M
