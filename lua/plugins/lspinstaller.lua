local lsp_installer = require "nvim-lsp-installer"
local vim_api = vim.api
local vim_lsp = vim.lsp

local capabilities = vim_lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)

-- do something on lsp on_attach
local function on_attach(_, bufnr)
   -- set mappings only in current buffer with lsp enabled
   local function buf_set_keymap(...)
      vim_api.nvim_buf_set_keymap(bufnr, ...)
   end

   -- set options only in current buffer with lsp enabled
   local function buf_set_option(...)
      vim_api.nvim_buf_set_option(bufnr, ...)
   end

   buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
   require("core.mappings").lsp(buf_set_keymap)
end

-- Register a handler that will be called for each installed server when it's ready (i.e. when installation is finished
-- or if the server is already installed).
lsp_installer.on_server_ready(function(server)
   local opts = {
      on_attach = on_attach,
      flags = {
         -- This will be the default in neovim 0.7+
         debounce_text_changes = 150,
      },
   }
   -- (optional) Customize the options passed to the server
   -- if server.name == "tsserver" then
   --     opts.root_dir = function() ... end
   -- end

   -- This setup() function will take the provided server configuration and decorate it with the necessary properties
   -- before passing it onwards to lspconfig.
   -- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
   if server.name ~= "volar" then
      server:setup(opts)
   end
end)
