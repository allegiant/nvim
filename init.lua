if vim.g.vscode then
  require("config.vscode")
else
  if vim.g.neovide then
    require("config.neovide")
  end
  require "core.options"
  require "core.autocmds"
  require "core.mappings"
  require "config.lazy"
  require "lspconfig"
end
