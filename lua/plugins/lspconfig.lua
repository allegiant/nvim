return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		vim.diagnostic.config({
			virtual_text = {
				prefix = "●", -- Could be '●', '▎', 'x', ■
				spacing = 4,
			},
			float = { border = "rounded" },
			signs = {
				text = {
					[vim.diagnostic.severity.HINT] = "",
					[vim.diagnostic.severity.INFO] = "",
					[vim.diagnostic.severity.WARN] = "",
					[vim.diagnostic.severity.ERROR] = "",
				},
			},
		})

		vim.lsp.config.lua_ls = {
			settings = require("lsp.lua_ls").opts.settings,
		}
		vim.lsp.enable("lua_ls")
		vim.lsp.enable("jsonls")
		vim.lsp.enable("pylsp")
		require("lsp.vue_ls")
	end,
}
