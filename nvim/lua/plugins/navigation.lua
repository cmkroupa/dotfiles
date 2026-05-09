return {
	-- breadcrumbs in statusline
	{
		"SmiteshP/nvim-navic",
		dependencies = { "neovim/nvim-lspconfig" },
		opts = { lsp = { auto_attach = true } },
	},
	-- symbols sidebar
	{
		"hedyhli/outline.nvim",
		keys = {
			{ "<leader>cs", "<cmd>Outline<cr>", desc = "Symbols outline" },
		},
		opts = {},
	},
	-- frecency file ranking
	{
		"nvim-telescope/telescope-frecency.nvim",
		dependencies = { "nvim-telescope/telescope.nvim" },
		config = function()
			require("telescope").load_extension("frecency")
		end,
		keys = {
			{ "<leader>fF", "<cmd>Telescope frecency workspace=CWD<cr>", desc = "Find files (frecency)" },
		},
	},
}
