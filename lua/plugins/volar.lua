local lspconfig = require'lspconfig'
local lspconfig_configs = require'lspconfig.configs'
local lspconfig_util = require 'lspconfig.util'
local vim_lsp = vim.lsp
local vim_uri_from_bufnr = vim.uri_from_bufnr

local function on_new_config(new_config, new_root_dir)
  local function get_typescript_server_path(root_dir)
    local project_root = lspconfig_util.find_node_modules_ancestor(root_dir)
    return project_root and (lspconfig_util.path.join(project_root, 'node_modules', 'typescript', 'lib', 'tsserverlibrary.js'))
      or ''
  end

  if
    new_config.init_options
    and new_config.init_options.typescript
    and new_config.init_options.typescript.serverPath == ''
  then
    new_config.init_options.typescript.serverPath = get_typescript_server_path(new_root_dir)
  end
end

local volar_cmd = {'vue-language-server', '--stdio'}
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
      vim_lsp.buf.execute_command({
        command = 'volar.html-to-pug',
        arguments = { vim_uri_from_bufnr(0) }
      })
    end,
  },
  VolarPugToHtml = {
    function()
      vim_lsp.buf.execute_command({
        command = 'volar.pug-to-html',
        arguments = { vim_uri_from_bufnr(0) }
      })
    end,
  },
  VolarUseSetupSugar = {
    function()
      vim_lsp.buf.execute_command({
        command = 'volar.use-setup-sugar',
        arguments = { vim_uri_from_bufnr(0) }
      })
    end,
  },
  VolarUnuseSetupSugar = {
    function()
      vim_lsp.buf.execute_command({
        command = 'volar.unuse-setup-sugar',
        arguments = { vim_uri_from_bufnr(0) }
      })
    end,
  },
  VolarUseRefSugar = {
    function()
      vim_lsp.buf.execute_command({
        command = 'volar.use-ref-sugar',
        arguments = { vim_uri_from_bufnr(0) }
      })
    end,
  },
  VolarUnuseRefSugar = {
    function()
      vim_lsp.buf.execute_command({
        command = 'volar.unuse-ref-sugar',
        arguments = { vim_uri_from_bufnr(0) }
      })
    end,
  },
  VolarShowReferences = {
    function()
      vim_lsp.buf.execute_command({
        command = 'volar.show-references',
        arguments = { vim_uri_from_bufnr(0) }
      })
    end,
  },
  VolarConvertToKebabCase = {
    function()
      vim_lsp.buf.execute_command({
        command = 'volar.server.executeConvertToKebabCase',
        arguments = { vim_uri_from_bufnr(0) }
      })
    end,
  },
  VolarConvertToPascalCase = {
    function()
      vim_lsp.buf.execute_command({
        command = 'volar.server.executeConvertToPascalCase',
        arguments = { vim_uri_from_bufnr(0) }
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
        codeLens = { showReferencesNotification = true},
        -- not supported - https://github.com/neovim/neovim/pull/15723
        semanticTokens = false,
        diagnostics = true,
        schemaRequestService = true,
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
        documentFormatting = {
          defaultPrintWidth = 100,
        },
      }
    },
  }
}

local M = {}
M.setup_api = function(opts)
  lspconfig.volar_api.setup(opts);
end
M.setup_doc = function(opts)
  lspconfig.volar_doc.setup(opts);
end

M.setup_html = function(opts)
  lspconfig.volar_html.setup(opts);
end

return M
