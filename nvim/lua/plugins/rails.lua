return {
	{
		"tpope/vim-rails",
		ft = { "ruby", "eruby" },
		config = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "ruby", "eruby" },
				callback = function(args)
					local map = vim.keymap.set
					local opts = { buffer = args.buf }
					local e = vim.tbl_extend
					map("n", "<leader>ra", "<cmd>A<cr>",           e("force", opts, { desc = "Alternate" }))
					map("n", "<leader>rr", "<cmd>R<cr>",           e("force", opts, { desc = "Related" }))
					map("n", "<leader>rc", "<cmd>Econtroller<cr>", e("force", opts, { desc = "Controller" }))
					map("n", "<leader>rm", "<cmd>Emodel<cr>",      e("force", opts, { desc = "Model" }))
					map("n", "<leader>rv", "<cmd>Eview<cr>",       e("force", opts, { desc = "View" }))
					map("n", "<leader>ri", "<cmd>Emigration<cr>",  e("force", opts, { desc = "Migration" }))
				end,
			})
		end,
	},
}
