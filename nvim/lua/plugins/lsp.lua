return {
	{ "williamboman/mason.nvim", opts = {} },
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		opts = {
			ensure_installed = { "pyright", "rust_analyzer", "clangd", "solargraph", "lua_ls" },
			automatic_installation = true,
		},
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "williamboman/mason-lspconfig.nvim" },
		config = function()
			vim.lsp.config("pyright", {})
			vim.lsp.config("rust_analyzer", {})
			vim.lsp.config("clangd", {})
			vim.lsp.config("solargraph", {})
			vim.lsp.config("lua_ls", {})

			vim.lsp.enable({ "pyright", "rust_analyzer", "clangd", "solargraph", "lua_ls" })

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local map = vim.keymap.set
					local opts = { buffer = args.buf }
					local e = vim.tbl_extend
					map("n", "gd", vim.lsp.buf.definition, e("force", opts, { desc = "Go to definition" }))
					map("n", "gr", vim.lsp.buf.references, e("force", opts, { desc = "References" }))
					map("n", "K", vim.lsp.buf.hover, e("force", opts, { desc = "Hover docs" }))
					map("n", "<leader>rn", vim.lsp.buf.rename, e("force", opts, { desc = "Rename symbol" }))
					map("n", "<leader>ca", vim.lsp.buf.code_action, e("force", opts, { desc = "Code action" }))
					map("n", "[d", vim.diagnostic.goto_prev, e("force", opts, { desc = "Prev diagnostic" }))
					map("n", "]d", vim.diagnostic.goto_next, e("force", opts, { desc = "Next diagnostic" }))
				end,
			})
		end,
	},
	{
		"p00f/clangd_extensions.nvim",
		ft = { "c", "cpp" },
		opts = {},
	},
}
