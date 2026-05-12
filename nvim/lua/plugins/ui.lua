return {
	-- theme
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		lazy = false,
		config = function()
			require("catppuccin").setup({ flavour = "mocha" })
			vim.cmd.colorscheme("catppuccin")
		end,
	},
	-- statusline
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "catppuccin/nvim", "SmiteshP/nvim-navic" },
		config = function()
			local navic = require("nvim-navic")
			require("lualine").setup({
				options = { theme = "auto" },
				sections = {
					lualine_c = {
						{ "filename" },
						{ navic.get_location, cond = navic.is_available },
					},
				},
			})
		end,
	},
	-- fancy cmdline + notifications
	{
		"folke/noice.nvim",
		dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
		opts = {},
	},
	-- indent guides
	{ "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
	-- git signs in gutter
	{ "lewis6991/gitsigns.nvim", opts = {} },
	-- todo/fixme highlights
	{ "folke/todo-comments.nvim", opts = {} },
	-- which-key
	{
		"folke/which-key.nvim",
		opts = {
			spec = {
				{ "<leader>f", group = "Find" },
				{ "<leader>h", group = "Harpoon" },
				{ "<leader>c", group = "Code" },
				{ "g",         group = "LSP" },
				{ "gz",        group = "Surround" },
				{ "[",         group = "Prev" },
				{ "]",         group = "Next" },
				{ "a",         group = "Around",  mode = { "o", "x" } },
				{ "i",         group = "Inside",  mode = { "o", "x" } },
			},
		},
	},
}
