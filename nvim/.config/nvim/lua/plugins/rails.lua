return {
	{
		"tpope/vim-rails",
		enabled = function()
			local ok, servers = pcall(require, "config.lsp_servers")
			if not ok or not servers or not servers.extra_lsp then
				return false
			end
			for _, v in ipairs(servers.extra_lsp) do
				if v == "ruby_lsp" then
					return true
				end
			end
			return false
		end,
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
