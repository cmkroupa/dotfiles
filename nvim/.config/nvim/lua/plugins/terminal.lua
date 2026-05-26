return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		keys = {
			{ "<leader>t", "<cmd>ToggleTerm<cr>", desc = "Terminal" },
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
