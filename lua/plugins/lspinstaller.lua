local lsp_installer = require "nvim-lsp-installer"
local vim_api = vim.api
local vim_lsp = vim.lsp

local capabilities = vim_lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)

capabilities.textDocument.completion.completionItem.snippetSupport = true

-- do something on lsp on_attach
local function on_attach(client, bufnr)
  --client.resolved_capabilities.document_formatting = false
  --client.resolved_capabilities.document_range_formatting = false

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
    capabilities = capabilities,
  }
  -- (optional) Customize the options passed to the server
  -- if server.name == "tsserver" then
  --     opts.root_dir = function() ... end
  -- end

  -- This setup() function will take the provided server configuration and decorate it with the necessary properties
  -- before passing it onwards to lspconfig.
  -- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md

  -- if server.name == "volar" then
  --   opts.filetypes = {'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue', 'json'}
  -- end
  -- server:setup(opts)
  if server.name == "rust_analyzer" then
    -- Initialize the LSP via rust-tools instead
    require("rust-tools").setup {
      -- The "server" property provided in rust-tools setup function are the
      -- settings rust-tools will provide to lspconfig during init.            -- 
      -- We merge the necessary settings from nvim-lsp-installer (server:get_default_options())
      -- with the user's own settings (opts).
      server = vim.tbl_deep_extend("force", server:get_default_options(), opts),
    }
    server:attach_buffers()
    -- Only if standalone support is needed
    require("rust-tools").start_standalone_if_required()
  elseif server.name ~= "volar" then
    server:setup(opts)
  end
end)
