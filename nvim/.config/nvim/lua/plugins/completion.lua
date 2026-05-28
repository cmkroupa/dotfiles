return {
	{
		"L3MON4D3/LuaSnip",
		dependencies = { "rafamadriz/friendly-snippets" },
		config = function()
			require("luasnip.loaders.from_vscode").lazy_load()
		end,
	},
	{
		"saghen/blink.cmp",
		version = "*",
		dependencies = { "L3MON4D3/LuaSnip" },
		opts = {
			keymap = {
				preset = "default",
				["<Tab>"] = { "accept", "fallback" },
			},
			appearance = {},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
			completion = {
				documentation = { auto_show = true, auto_show_delay_ms = 500 },
				menu = { auto_show_delay_ms = 1000 },
			},
			signature = { enabled = true },
			snippets = {
				expand = function(snippet)
					require("luasnip").lsp_expand(snippet)
				end,
			},
		},
		config = function(_, opts)
			require("blink.cmp").setup(opts)
		end,
	},
}
