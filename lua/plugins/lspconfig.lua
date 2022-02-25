local lspconfig = require "lspconfig"
local lspconfig_configs = require "lspconfig.configs"
local lspconfig_util = require "lspconfig.util"
local vim_api = vim.api
local vim_lsp = vim.lsp

local function goto_definition(split_cmd)
  local util = vim.lsp.util
  local log = require "vim.lsp.log"
  local api = vim.api

  -- note, this handler style is for neovim 0.5.1/0.6, if on 0.5, call with function(_, method, result)
  local handler = function(_, result, ctx)
    if result == nil or vim.tbl_isempty(result) then
      local _ = log.info() and log.info(ctx.method, "No location found")
      return nil
    end

    if split_cmd then
      vim.cmd(split_cmd)
    end

    if vim.tbl_islist(result) then
      util.jump_to_location(result[1])

      if #result > 1 then
        util.set_qflist(util.locations_to_items(result))
        api.nvim_command "copen"
        api.nvim_command "wincmd p"
      end
    else
      util.jump_to_location(result)
    end
  end

  return handler
end

local function on_attach(client, bufnr)
  client.resolved_capabilities.document_formatting = false
  client.resolved_capabilities.document_range_formatting = false

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

local function on_new_config(new_config, new_root_dir)
  local function get_typescript_server_path(root_dir)
    local project_root = lspconfig_util.find_node_modules_ancestor(root_dir)
    return project_root
        and (lspconfig_util.path.join(project_root, "node_modules", "typescript", "lib", "tsserverlibrary.js"))
      or ""
  end

  if
    new_config.init_options
    and new_config.init_options.typescript
    and new_config.init_options.typescript.serverPath == ""
  then
    new_config.init_options.typescript.serverPath = get_typescript_server_path(new_root_dir)
  end
end

local volar_cmd = { "volar-server", "--stdio" }
local volar_root_dir = lspconfig_util.root_pattern "package.json"

lspconfig_configs.volar_api = {
  default_config = {
    cmd = volar_cmd,
    root_dir = volar_root_dir,
    on_new_config = on_new_config,
    filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue", "json" },
    init_options = {
      typescript = {
        serverPath = "",
      },
      languageFeatures = {
        references = true,
        definition = true,
        typeDefinition = true,
        callHierarchy = true,
        hover = true,
        rename = true,
        renameFileRefactoring = true,
        signatureHelp = true,
        codeAction = true,
        workspaceSymbol = true,
        completion = {
          defaultTagNameCase = "both",
          defaultAttrNameCase = "kebabCase",
          getDocumentNameCasesRequest = false,
          getDocumentSelectionRequest = false,
        },
      },
    },
  },
}

lspconfig_configs.volar_doc = {
  default_config = {
    cmd = volar_cmd,
    root_dir = volar_root_dir,
    on_new_config = on_new_config,

    filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue", "json" },
    init_options = {
      typescript = {
        serverPath = "",
      },
      languageFeatures = {
        documentHighlight = true,
        documentLink = true,
        codeLens = { showReferencesNotification = true },
        -- not supported - https://github.com/neovim/neovim/pull/14122
        semanticTokens = false,
        diagnostics = true,
        schemaRequestService = true,
      },
    },
  },
}

lspconfig_configs.volar_html = {
  default_config = {
    cmd = volar_cmd,
    root_dir = volar_root_dir,
    on_new_config = on_new_config,
    filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
    init_options = {
      typescript = {
        serverPath = "",
      },
      documentFeatures = {
        selectionRange = true,
        foldingRange = true,
        linkedEditingRange = true,
        documentSymbol = true,
        -- not supported - https://github.com/neovim/neovim/pull/13654
        documentColor = false,
        documentFormatting = {
          defaultPrintWidth = 100,
        },
      },
    },
  },
}

local M = {}

M.setup = function()
vim.lsp.handlers["textDocument/definition"] = goto_definition('split')
  -- lspconfig.volar_api.setup {
  --   on_attach = on_attach,
  --   flags = {
  --     -- This will be the default in neovim 0.7+
  --     debounce_text_changes = 150,
  --   },
  -- }
  -- lspconfig.volar_doc.setup {
  --   on_attach = on_attach,
  --   flags = {
  --     -- This will be the default in neovim 0.7+
  --     debounce_text_changes = 150,
  --   },
  -- }
  -- lspconfig.volar_html.setup {
  --   on_attach = on_attach,
  --   flags = {
  --     -- This will be the default in neovim 0.7+
  --     debounce_text_changes = 150,
  --   },
  -- }
end

return M
