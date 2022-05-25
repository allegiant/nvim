local lspconfig = require 'lspconfig'
local lspconfig_configs = require 'lspconfig.configs'
local lspconfig_util = require 'lspconfig.util'

local function on_new_config(new_config, new_root_dir)
  local function get_typescript_server_path(root_dir)
    local project_root = lspconfig_util.find_node_modules_ancestor(root_dir)
    return project_root and (lspconfig_util.path.join(project_root, 'node_modules', 'typescript', 'lib', 'tsserverlibrary.js'))
        or ''
  end

  if new_config.init_options
      and new_config.init_options.typescript
      and new_config.init_options.typescript.serverPath == ''
  then
    new_config.init_options.typescript.serverPath = get_typescript_server_path(new_root_dir)
  end
end

local volar_cmd = { 'vue-language-server', '--stdio' }
local volar_root_dir = lspconfig_util.root_pattern 'package.json'

local filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' };
local filetypes_with_json = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue', 'json' }

local settings = {
  volar = {
    codeLens = {
      scriptSetupTools = true,
      references = true,
      pugTools = true,
    },
    lowPowerMode = false,
    formatting = { printWidth = 100 },
    autoCompleteRefs = true,
    -- what am i smoking this is a vscode client option
    takeOverMode = { enabled = true }, -- default is "auto" which launches only when builtin vscode TS ext is enabled. wonder how that logic behaves in neovim where there's no such builtin TS ext
    completion = {
      preferredTagNameCase = 'pascal',
      preferredAttrNameCase = 'kebab',
      autoImportComponent = true,
    },
    preview = {
      port = 3333,
      backgroundColor = '#fff',
      transparentGrid = true,
    }
  },
  ['volar-api'] = {
    trace = {
      server = 'verbose'
    }
  },
  ['volar-document'] = {
    trace = {
      server = 'verbose'
    }
  },
  ['volar-html'] = {
    trace = {
      server = 'verbose'
    }
  },
}

local commands = {
  VolarHtmlToPug = {
    function()
      vim.lsp.buf.execute_command({
        command = 'volar.html-to-pug',
        arguments = { vim.uri_from_bufnr(0) }
      })
    end,
  },
  VolarPugToHtml = {
    function()
      vim.lsp.buf.execute_command({
        command = 'volar.pug-to-html',
        arguments = { vim.uri_from_bufnr(0) }
      })
    end,
  },
  VolarUseSetupSugar = {
    function()
      vim.lsp.buf.execute_command({
        command = 'volar.use-setup-sugar',
        arguments = { vim.uri_from_bufnr(0) }
      })
    end,
  },
  VolarUnuseSetupSugar = {
    function()
      vim.lsp.buf.execute_command({
        command = 'volar.unuse-setup-sugar',
        arguments = { vim.uri_from_bufnr(0) }
      })
    end,
  },
  VolarUseRefSugar = {
    function()
      vim.lsp.buf.execute_command({
        command = 'volar.use-ref-sugar',
        arguments = { vim.uri_from_bufnr(0) }
      })
    end,
  },
  VolarUnuseRefSugar = {
    function()
      vim.lsp.buf.execute_command({
        command = 'volar.unuse-ref-sugar',
        arguments = { vim.uri_from_bufnr(0) }
      })
    end,
  },
  VolarShowReferences = {
    function()
      vim.lsp.buf.execute_command({
        command = 'volar.show-references',
        arguments = { vim.uri_from_bufnr(0) }
      })
    end,
  },
  VolarConvertToKebabCase = {
    function()
      vim.lsp.buf.execute_command({
        command = 'volar.server.executeConvertToKebabCase',
        arguments = { vim.uri_from_bufnr(0) }
      })
    end,
  },
  VolarConvertToPascalCase = {
    function()
      vim.lsp.buf.execute_command({
        command = 'volar.server.executeConvertToPascalCase',
        arguments = { vim.uri_from_bufnr(0) }
      })
    end,
  },
}

lspconfig_configs.volar_api = {
  default_config = {
    cmd = volar_cmd,
    root_dir = volar_root_dir,
    on_new_config = on_new_config,
    settings = settings,
    commands = commands,
    filetypes = filetypes_with_json,
    init_options = {
      typescript = {
        serverPath = ''
      },
      languageFeatures = {
        implementation = true, -- new in @volar/vue-language-server v0.33
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
          defaultTagNameCase = 'both',
          defaultAttrNameCase = 'kebabCase',
          getDocumentNameCasesRequest = false,
          getDocumentSelectionRequest = false,
        },
      }
    },
  }
}

lspconfig_configs.volar_doc = {
  default_config = {
    cmd = volar_cmd,
    root_dir = volar_root_dir,
    on_new_config = on_new_config,
    settings = settings,
    filetypes = filetypes_with_json,
    init_options = {
      typescript = {
        serverPath = ''
      },
      languageFeatures = {
        implementation = true, -- new in @volar/vue-language-server v0.33
        documentHighlight = true,
        documentLink = true,
        codeLens = { showReferencesNotification = true },
        -- not supported - https://github.com/neovim/neovim/pull/15723
        -- semanticTokens = false,
        diagnostics = { getDocumentVersionRequest = false }, -- if you set this to true it'll crash volar-doc with "MethodNotFound: vue/docVersion"
          schemaRequestService = { getDocumentContentRequest = false } -- dunno if this crashes the ls but I'm disabling because I'm scared
      }
    },
  }
}

lspconfig_configs.volar_html = {
  default_config = {
    cmd = volar_cmd,
    root_dir = volar_root_dir,
    on_new_config = on_new_config,
    settings = settings,
    filetypes = filetypes,
    init_options = {
      typescript = {
        serverPath = ''
      },
      documentFeatures = {
        selectionRange = true,
        foldingRange = true,
        linkedEditingRange = true,
        documentSymbol = true,
        -- not supported - https://github.com/neovim/neovim/pull/13654
        documentColor = false,
        -- documentFormatting = {
        --   defaultPrintWidth = 100,
        --   getDocumentPrintWidthRequest = 100
        -- },
      }
    },
  }
}


local M = {}


M.setup = function(on_attach)
  lspconfig.volar_api.setup {
    on_attach = on_attach
  };
  lspconfig.volar_doc.setup {
    on_attach = on_attach
  };
  lspconfig.volar_html.setup {
    on_attach = on_attach
  };
end

return M
