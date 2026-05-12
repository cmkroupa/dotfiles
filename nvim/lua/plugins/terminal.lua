return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		keys = {
			{ "<leader>t", "<cmd>ToggleTerm<cr>", desc = "Terminal" },
			{ "<C-\\>",    "<cmd>ToggleTerm<cr>", mode = "n" },
		},
		opts = {
			direction = "float",
			float_opts = { border = "rounded" },
			on_open = function(term)
				vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { buffer = term.bufnr })
			end,
		},
	},
}
