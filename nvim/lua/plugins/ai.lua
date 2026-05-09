return {
	{
		"olimorris/codecompanion.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("codecompanion").setup({
				adapters = {
					ollama = function()
						return require("codecompanion.adapters").extend("ollama", {
							schema = {
								model = { default = "qwen2.5-coder:14b" },
							},
						})
					end,
				},
				strategies = {
					chat = { adapter = "ollama" },
					inline = { adapter = "ollama" },
					agent = { adapter = "ollama" },
				},
			})

			local map = vim.keymap.set
			map("n", "<leader>ac", "<cmd>CodeCompanionChat<cr>", { desc = "AI chat" })
			map("n", "<leader>ai", "<cmd>CodeCompanion<cr>", { desc = "AI inline" })
			map("v", "<leader>ai", "<cmd>CodeCompanion<cr>", { desc = "AI inline (selection)" })
			map("v", "<leader>ae", "<cmd>CodeCompanion /explain<cr>", { desc = "AI explain" })
			map("v", "<leader>af", "<cmd>CodeCompanion /fix<cr>", { desc = "AI fix" })
			map("v", "<leader>ar", "<cmd>CodeCompanion /refactor<cr>", { desc = "AI refactor" })
			map("n", "<leader>at", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "AI chat toggle" })
			map("v", "<leader>at", "<cmd>CodeCompanionChat Add<cr>", { desc = "AI add selection to chat" })
		end,
	},
}
