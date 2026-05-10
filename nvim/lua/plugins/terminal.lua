return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		keys = {
			{ "<C-\\>", "<cmd>ToggleTerm<cr>", mode = { "n", "t" }, desc = "Toggle terminal" },
			{ "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
			{ "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Float terminal" },
			{ "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Horizontal terminal" },
		},
		opts = {
			direction = "float",
			float_opts = { border = "rounded" },
			-- <C-\> in terminal mode goes back to normal mode, then closes
			on_open = function(term)
				vim.keymap.set("t", "<C-\\>", "<cmd>ToggleTerm<cr>", { buffer = term.bufnr, desc = "Toggle terminal" })
			end,
		},
	},
}
