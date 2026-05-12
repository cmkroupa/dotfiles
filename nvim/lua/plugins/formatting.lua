return {
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				python = { "black" },
				rust   = { "rustfmt" },
				c      = { "clang_format" },
				cpp    = { "clang_format" },
				ruby   = { "rubocop" },
				eruby  = { "rubocop" },
				go     = { "gofmt" },
				lua    = { "stylua" },
			},
			formatters = {
				clang_format = {
					prepend_args = { "--style={IndentWidth: 4, UseTab: Never}" },
				},
				stylua = {
					prepend_args = { "--indent-type", "Spaces", "--indent-width", "4" },
				},
			},
			format_on_save = {
				timeout_ms = 500,
				lsp_fallback = true,
			},
		},
	},
	{
		"mfussenegger/nvim-lint",
		config = function()
			local lint = require("lint")
			lint.linters_by_ft = {
				python = { "ruff" },
				ruby = { "rubocop" },
			}
			vim.api.nvim_create_autocmd({ "BufWritePost" }, {
				callback = function()
					lint.try_lint()
				end,
			})
		end,
	},
}
