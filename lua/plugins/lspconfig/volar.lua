local M = {}

M.setup = function(lspconfig, capabilities)
  lspconfig.volar.setup {
    filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue', 'json' },
    capabilities = capabilities,
    settings = {
      volar = {
        disableFormatting = false,
        vueserver = {
          textDocumentSync = "incremental",
          diagnosticModel = "pull",
        },
        completion = {
          preferredTagNameCase = 'kebab',
          preferredAttrNameCase = 'kebab',
        },
      }
    },
    init_options = {
      documentFeatures = {
        documentColor = false,
        documentFormatting = {
          defaultPrintWidth = 100,
        },
        documentSymbol = true,
        foldingRange = true,
        linkedEditingRange = true,
        selectionRange = true
      },
      languageFeatures = {
        callHierarchy = true,
        codeAction = true,
        codeLens = true,
        completion = {
          defaultAttrNameCase = "kebabCase",
          defaultTagNameCase = "both"
        },
        definition = true,
        diagnostics = true,
        documentHighlight = true,
        documentLink = true,
        hover = true,
        implementation = true,
        references = true,
        rename = true,
        renameFileRefactoring = true,
        schemaRequestService = true,
        semanticTokens = false,
        signatureHelp = true,
        typeDefinition = true
      },
      typescript = {
        tsdk = ""
      }
    }
  }
end

return M
