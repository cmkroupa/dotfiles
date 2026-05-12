return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-live-grep-args.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		},
		config = function()
			local telescope = require("telescope")
			local lga_actions = require("telescope-live-grep-args.actions")

			telescope.setup({
				defaults = {
					file_ignore_patterns = {
						"node_modules", "vendor/", "tmp/", "log/",
						"%.git/", "%.lock", "%.png", "%.jpg", "%.jpeg",
						"%.gif", "%.min.js", "%.map", "public/assets",
					},
					vimgrep_arguments = {
						"rg", "--color=never", "--no-heading", "--with-filename",
						"--line-number", "--column", "--smart-case", "--hidden", "--glob=!.git/",
					},
					path_display = { "truncate" },
				},
				extensions = {
					live_grep_args = {
						auto_quoting = true,
						mappings = { i = { ["<C-k>"] = lga_actions.quote_prompt() } },
					},
				},
			})

			telescope.load_extension("fzf")
			telescope.load_extension("live_grep_args")
		end,
		keys = {
			{ "<leader>ff", "<cmd>Telescope find_files<cr>",                desc = "Find Files" },
			{ "<leader>fw", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Find Word" },
			{ "<leader>fg", "<cmd>Telescope live_grep_args<cr>",            desc = "Grep" },
		},
	},
}
