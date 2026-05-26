return {
	{ "numToStr/Comment.nvim", event = "VeryLazy", opts = {} },
	{ "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
	{ "windwp/nvim-ts-autotag", ft = { "html", "eruby" }, opts = {} },
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {},
		keys = {
			{ "s", function() require("flash").jump() end,       mode = { "n", "x", "o" }, desc = "Flash Jump" },
			{ "S", function() require("flash").treesitter() end, mode = { "n", "x", "o" }, desc = "TS Jump" },
		},
	},
}
