return {
	{
		"echasnovski/mini.surround",
		opts = {
			mappings = {
				add            = "gza",
				delete         = "gzd",
				replace        = "gzr",
				find           = "gzf",
				find_left      = "gzF",
				highlight      = "gzh",
				update_n_lines = "gzn",
			},
		},
	},
	{ "folke/trouble.nvim", opts = {} },
	{ "christoomey/vim-tmux-navigator", lazy = false },
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
		opts = {
			ensure_installed = {
				"python", "rust", "c", "cpp", "ruby", "lua", "vim", "vimdoc",
				"go", "html", "css", "javascript", "typescript", "json", "yaml",
				"bash", "toml", "markdown", "markdown_inline",
			},
			auto_install = true,
			highlight = { enable = true },
			indent    = { enable = true },
			matchup   = { enable = false },
			textobjects = {
				select = {
					enable    = true,
					lookahead = true,
					keymaps = {
						["af"] = { query = "@function.outer",  desc = "Around function" },
						["if"] = { query = "@function.inner",  desc = "Inside function" },
						["ac"] = { query = "@class.outer",     desc = "Around class" },
						["ic"] = { query = "@class.inner",     desc = "Inside class" },
						["aa"] = { query = "@parameter.outer", desc = "Around argument" },
						["ia"] = { query = "@parameter.inner", desc = "Inside argument" },
					},
				},
				move = {
					enable    = true,
					set_jumps = true,
					goto_next_start = {
						["]f"] = { query = "@function.outer", desc = "Next function" },
						["]t"] = { query = "@class.outer",    desc = "Next class" },
					},
					goto_previous_start = {
						["[f"] = { query = "@function.outer", desc = "Prev function" },
						["[t"] = { query = "@class.outer",    desc = "Prev class" },
					},
				},
			},
		},
		config = function(_, opts)
			require("nvim-treesitter").setup(opts)
			vim.treesitter.query.add_directive(
				"set-lang-from-info-string!",
				function(match, _, bufnr, pred, metadata)
					local node = match[pred[2]]
					if type(node) == "table" then node = node[1] end
					if not node then return end
					local ok, text = pcall(vim.treesitter.get_node_text, node, bufnr)
					if ok and text then
						metadata["injection.language"] = text:lower():gsub("^%s*(.-)%s*$", "%1")
					end
				end,
				{ force = true }
			)
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		opts = { max_lines = 3 },
		config = function(_, opts)
			local ctx = require("treesitter-context")
			ctx.setup(opts)

			local function refresh()
				ctx.disable()
				vim.schedule(ctx.enable)
			end

			-- Hide while moving so there's zero per-keypress overhead
			vim.api.nvim_create_autocmd("CursorMoved", { callback = ctx.disable })
			-- Show on idle and on buffer load
			vim.api.nvim_create_autocmd("CursorHold",  { callback = refresh })
			vim.api.nvim_create_autocmd("BufEnter",    { callback = refresh })
		end,
	},
	{
		"RRethy/vim-illuminate",
		event = { "BufReadPost", "BufNewFile" },
		opts = { delay = 500, large_file_cutoff = 2000, providers = { "lsp", "regex" } },
		config = function(_, opts)
			require("illuminate").configure(opts)
		end,
	},
	{ "j-hui/fidget.nvim", opts = {} },
	{
		"andymass/vim-matchup",
		init = function()
			vim.g.matchup_matchparen_offscreen = { method = "status" }
			vim.g.matchup_treesitter_enabled = 0
		end,
	},
}
