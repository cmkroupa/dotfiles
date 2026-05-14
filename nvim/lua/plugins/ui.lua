return {
	-- theme (priority ensures it loads before everything else)
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		lazy = false,
		opts = {
			flavour = "mocha",
			integrations = {
				bufferline        = true,
				gitsigns          = true,
				harpoon           = true,
				illuminate        = { enabled = true },
				indent_blankline  = { enabled = true },
				lsp_trouble       = true,
				mason             = true,
				mini              = { enabled = true },
				navic             = { enabled = true, custom_bg = "NONE" },
				noice             = true,
				notify            = true,
				telescope         = { enabled = true },
				treesitter        = true,
				treesitter_context = true,
				which_key         = true,
			},
		},
		config = function(_, opts)
			require("catppuccin").setup(opts)
			vim.cmd.colorscheme("catppuccin")
		end,
	},
	-- buffer tabline (catppuccin highlights applied after theme loads)
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = {
				mode = "buffers",
				diagnostics = "nvim_lsp",
				diagnostics_indicator = function(_, _, diag)
					local icons = { error = " ", warning = " " }
					return (diag.error and icons.error .. diag.error or "")
						.. (diag.warning and icons.warning .. diag.warning or "")
				end,
				show_buffer_close_icons = false,
				show_close_icon = false,
				separator_style = "thin",
			},
		},
	},
	-- statusline
	{
		"nvim-lualine/lualine.nvim",
		lazy = false,
		priority = 999,
		dependencies = { "catppuccin/nvim", "SmiteshP/nvim-navic" },
		config = function()
			require("lualine").setup({
				options = {
					theme = "catppuccin-mocha",
					globalstatus = true,
					section_separators = "",
					component_separators = "|",
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff" },
					lualine_c = {
						{ "filename", path = 1 },
						"diagnostics",
						{
							function() return require("nvim-navic").get_location() end,
							cond = function()
								return package.loaded["nvim-navic"]
									and require("nvim-navic").is_available()
							end,
						},
					},
					lualine_x = { "filetype" },
					lualine_y = {},
					lualine_z = { "location" },
				},
			})
		end,
	},
	-- fancy cmdline + notifications
	{
		"folke/noice.nvim",
		dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
		opts = {
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
				},
			},
			presets = {
				bottom_search        = true,
				command_palette      = true,
				long_message_to_split = true,
				lsp_doc_border       = true,
			},
		},
	},
	-- indent guides with scope highlight
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {
			scope = { enabled = true, show_start = true },
		},
	},
	-- git signs in gutter
	{ "lewis6991/gitsigns.nvim", opts = {} },
	-- todo/fixme highlights
	{ "folke/todo-comments.nvim", opts = {} },
	-- which-key
	{
		"folke/which-key.nvim",
		opts = {
			spec = {
				{ "<leader>s", group = "Search" },
				{ "<leader>f", group = "Format" },
				{ "<leader>p", group = "Pins" },
				{ "<leader>c", group = "Code/Actions" },
				{ "<leader>r", group = "Rails" },
				{ "<leader>g", icon = { icon = "󰊢", color = "red" } },
				{ "gz",        group = "Surround" },
				{ "[",         group = "Prev" },
				{ "]",         group = "Next" },
				{ "a",         group = "Around", mode = { "o", "x" } },
				{ "i",         group = "Inside", mode = { "o", "x" } },
			},
		},
	},
}
