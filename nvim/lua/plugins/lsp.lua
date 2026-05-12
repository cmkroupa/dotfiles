return {
	{ "williamboman/mason.nvim", opts = {} },
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		opts = {
			ensure_installed = {
				-- Ruby / Rails
				"ruby_lsp",
				-- Web (ERB templates, HTML, CSS)
				"html", "cssls", "emmet_ls",
				-- C / C++
				"clangd", "cmake",
				-- Python, Go, Rust, Lua
				"pyright", "gopls", "rust_analyzer", "lua_ls",
			},
			automatic_installation = true,
		},
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "williamboman/mason-lspconfig.nvim" },
		config = function()
			-- Ruby / Rails
			vim.lsp.config("ruby_lsp", {})
			-- Web
			vim.lsp.config("html", {})
			vim.lsp.config("cssls", {})
			vim.lsp.config("emmet_ls", {
				filetypes = { "html", "eruby", "css", "scss" },
			})
			-- C / C++
			vim.lsp.config("clangd", {})
			vim.lsp.config("cmake", {})
			-- Others
			vim.lsp.config("pyright", {})
			vim.lsp.config("gopls", {})
			vim.lsp.config("rust_analyzer", {})
			vim.lsp.config("lua_ls", {})

			vim.lsp.enable({
				"ruby_lsp",
				"html", "cssls", "emmet_ls",
				"clangd", "cmake",
				"pyright", "gopls", "rust_analyzer", "lua_ls",
			})

			local map = vim.keymap.set
			map("n", "gh", function() require("telescope.builtin").lsp_definitions() end,     { desc = "Definition" })
			map("n", "gr", function() require("telescope.builtin").lsp_references() end,      { desc = "References" })
			map("n", "gC", function() require("telescope.builtin").lsp_implementations() end, { desc = "Implementation" })
			map("n", "K",  vim.lsp.buf.hover,                                                 { desc = "Hover Docs" })

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local opts = { buffer = args.buf }
					local e    = vim.tbl_extend
					map("n", "<leader>rn", vim.lsp.buf.rename,      e("force", opts, { desc = "Rename" }))
					map("n", "<leader>ca", vim.lsp.buf.code_action, e("force", opts, { desc = "Code Action" }))
					map("n", "[d", vim.diagnostic.goto_prev,        e("force", opts, { desc = "Prev Error" }))
					map("n", "]d", vim.diagnostic.goto_next,        e("force", opts, { desc = "Next Error" }))
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
