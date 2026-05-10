return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		keys = {
			{ "<C-\\>", "<cmd>ToggleTerm<cr>", mode = "n", desc = "Toggle terminal" },
			{ "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
		},
		opts = {
			direction = "float",
			float_opts = { border = "rounded" },
			on_open = function(term)
				-- Esc goes to normal mode so :q works
				vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { buffer = term.bufnr })
			end,
		},
	},
}
