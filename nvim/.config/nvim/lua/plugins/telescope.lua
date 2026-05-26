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
					live_grep_args = { auto_quoting = true },
				},
			})

			telescope.load_extension("fzf")
			telescope.load_extension("live_grep_args")
		end,
		keys = {
			{ "<leader>sf", "<cmd>Telescope find_files<cr>",                desc = "Files" },
			{ "<leader>sw", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Word" },
			{ "<leader>sg", "<cmd>Telescope live_grep_args<cr>",            desc = "Grep" },
			{ "<leader>sb", "<cmd>Telescope buffers<cr>",                   desc = "Buffers" },
			{ "<leader>st", function()
				local root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
				if not root or root == "" then root = vim.fn.getcwd() end
				require("telescope.builtin").grep_string({
					prompt_title = "Find Type",
					search = "\\b(struct|class|enum)\\s+\\w+",
					use_regex = true,
					search_dirs = { root },
					additional_args = { "--pcre2", "--glob=*.{cpp,hpp,h,c}" },
				})
			end, desc = "Types" },
			{ "<leader>sm", function()
				local root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
				if not root or root == "" then root = vim.fn.getcwd() end
				require("telescope.builtin").grep_string({
					prompt_title = "Find Method",
					search = "^\\s*(?!if\\b|for\\b|while\\b|switch\\b|return\\b|else\\b|#)[\\w:<>*&~ ]+\\s+\\w+\\s*\\(",
					use_regex = true,
					search_dirs = { root },
					additional_args = { "--pcre2", "--glob=*.{cpp,hpp,h,c}" },
				})
			end, desc = "Methods" },
		},
	},
}
