return {
	{ "echasnovski/mini.pairs", opts = {} },
	{ "echasnovski/mini.surround", opts = {} },
	{ "folke/trouble.nvim", opts = {} },
	{
		"christoomey/vim-tmux-navigator",
		lazy = false,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		opts = {
			ensure_installed = { "python", "rust", "c", "cpp", "ruby", "lua", "vim", "vimdoc" },
			highlight = { enable = true },
			indent = { enable = true },
			matchup = { enable = false },
		},
		config = function(_, opts)
			require("nvim-treesitter").setup(opts)
			-- Neovim 0.12 changed match[capture_id] to return a list of nodes
			-- instead of a single node. nvim-treesitter's directives haven't
			-- been updated yet, so we patch the broken one here.
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
	-- shows current function/class at top when scrolled past it
	{
		"nvim-treesitter/nvim-treesitter-context",
		opts = { max_lines = 3 },
	},
	-- LSP progress indicator
	{
		"j-hui/fidget.nvim",
		opts = {},
	},
	-- visual undo history
	{
		"mbbill/undotree",
		keys = {
			{ "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Undo tree" },
		},
	},
	-- better % jumping for Ruby def/end, if/endif etc
	{
		"andymass/vim-matchup",
		init = function()
			vim.g.matchup_matchparen_offscreen = { method = "popup" }
			vim.g.matchup_treesitter_enabled = 0  -- own TS integration hits nil-node bug
		end,
	},
}
