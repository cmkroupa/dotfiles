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
		"ThePrimeagen/vim-be-good",
		keys = {
			{ "<leader>vg", "<cmd>VimBeGood<cr>" },
		},
	},
}
