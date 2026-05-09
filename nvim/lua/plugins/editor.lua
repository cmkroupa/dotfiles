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
		opts = {
			matchup = {
				enable = true,
				disable_virtual_text = true,
			},
		},
	},
}
