return {
	{ "numToStr/Comment.nvim", lazy = false, opts = {} },
	{ "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
	{ "windwp/nvim-ts-autotag", opts = {} },
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {},
		keys = {
			{ "s", function() require("flash").jump() end,       mode = { "n", "x", "o" }, desc = "Flash Jump" },
			{ "S", function() require("flash").treesitter() end, mode = { "n", "x", "o" }, desc = "TS Jump" },
		},
	},
	{
		"stevearc/oil.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		lazy = false,
		keys = {
			{ "<leader>o", function() require("oil").open_float() end, desc = "Files" },
		},
		opts = {},
	},
	{
		"abecodes/tabout.nvim",
		event = "InsertEnter",
		opts = {
			tabkey          = "<Tab>",
			backwards_tabkey = "<S-Tab>",
			act_as_tab      = true,
			completion      = true,
		},
	},
	{
		"ThePrimeagen/vim-be-good",
		keys = {
			{ "<leader>vg", "<cmd>VimBeGood<cr>", desc = "Vim Be Good" },
		},
	},
	{
		"Wansmer/treesj",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		keys = {
			{ "<leader>j", function() require("treesj").toggle() end, desc = "Join/Split" },
		},
		opts = { use_default_keymaps = false },
	},
}
