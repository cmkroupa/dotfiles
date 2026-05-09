return {
	{
		"nvim-pack/nvim-spectre",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{ "<leader>sr", "<cmd>Spectre<cr>", desc = "Search & Replace" },
			{
				"<leader>sw",
				function()
					require("spectre").open_visual({ select_word = true })
				end,
				desc = "Search current word",
			},
		},
	},
	{
		"kevinhwang91/nvim-bqf",
		ft = "qf",
		opts = {},
	},
}
