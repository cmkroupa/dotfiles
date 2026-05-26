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
			keymap = { preset = "default" },
			appearance = {},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
			completion = {
				documentation = { auto_show = false },
				trigger = {
					show_on_keyword                     = false,
					show_on_trigger_character           = false,
					show_on_insert_on_trigger_character = false,
					show_on_accept_on_trigger_character = false,
				},
			},
			snippets = {
				expand = function(snippet)
					require("luasnip").lsp_expand(snippet)
				end,
			},
		},
		config = function(_, opts)
			require("blink.cmp").setup(opts)

			-- Show completion after 500ms pause while typing, never while actively typing
			local timer = (vim.uv or vim.loop).new_timer()
			vim.api.nvim_create_autocmd("TextChangedI", {
				callback = function()
					timer:stop()
					timer:start(2000, 0, vim.schedule_wrap(function()
						if vim.fn.mode() == "i" then
							require("blink.cmp").show()
						end
					end))
				end,
			})
			vim.api.nvim_create_autocmd("InsertLeave", {
				callback = function() timer:stop() end,
			})
		end,
	},
}
