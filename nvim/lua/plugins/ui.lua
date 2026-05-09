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
	-- buffer tabs
	{
		"akinsho/bufferline.nvim",
		opts = { options = { separator_style = "slant" } },
	},
	-- fancy cmdline + notifications
	{
		"folke/noice.nvim",
		dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
		opts = {},
	},
	-- indent guides
	{ "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
	-- git signs
	{ "lewis6991/gitsigns.nvim", opts = {} },
	-- todo highlights
	{ "folke/todo-comments.nvim", opts = {} },
	-- file tree
	{
		"nvim-neo-tree/neo-tree.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
		opts = {},
	},
	-- which-key
	{ "folke/which-key.nvim", opts = {} },
}
