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
					-- ignore these in all searches
					file_ignore_patterns = {
						"node_modules",
						"vendor/",
						"tmp/",
						"log/",
						"%.git/",
						"%.lock",
						"%.png",
						"%.jpg",
						"%.jpeg",
						"%.gif",
						"%.min.js",
						"%.map",
						"public/assets",
					},
					vimgrep_arguments = {
						"rg",
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
						"--hidden",
						"--glob=!.git/",
					},
					path_display = { "truncate" },
					layout_strategy = "horizontal",
					layout_config = {
						horizontal = { preview_width = 0.55 },
						width = 0.87,
						height = 0.80,
					},
				},
				extensions = {
					live_grep_args = {
						auto_quoting = true,
						mappings = {
							i = {
								["<C-k>"] = lga_actions.quote_prompt(),
								["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
								["<C-t>"] = lga_actions.quote_prompt({ postfix = " --type " }),
							},
						},
					},
				},
			})

			telescope.load_extension("fzf")
			telescope.load_extension("live_grep_args")
		end,
		keys = {
			{ "<leader>ff", "<cmd>Telescope find_files cwd=~<cr>", desc = "Find files" },
			{ "<leader>fg", "<cmd>Telescope live_grep_args cwd=~<cr>", desc = "Live grep (with args)" },
			{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
			{ "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "LSP symbols" },
			{ "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
			{ "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
		},
	},
}
