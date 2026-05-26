local ok, active_theme = pcall(require, "config.theme")
if not ok or not active_theme then
	active_theme = "catppuccin"
end

return {
	-- theme support (priority ensures they load before everything else)
	{ "folke/tokyonight.nvim", lazy = false, priority = 1001 },
	{ "ellisonleao/gruvbox.nvim", lazy = false, priority = 1001 },
	{ "shaunsingh/nord.nvim", lazy = false, priority = 1001 },
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		lazy = false,
		opts = {
			flavour = "macchiato",
			integrations = {
				bufferline        = true,
				gitsigns          = true,
				harpoon           = true,
				illuminate        = { enabled = true },
				indent_blankline  = { enabled = true },
				lsp_trouble       = true,
				mason             = true,
				mini              = { enabled = true },
				noice             = true,
				notify            = true,
				telescope         = { enabled = true },
				treesitter        = true,
				treesitter_context = true,
				which_key         = true,
			},
		},
		config = function(_, opts)
			require("catppuccin").setup(opts)
			if active_theme == "tokyonight" then
				vim.cmd.colorscheme("tokyonight-night")
			elseif active_theme == "gruvbox" then
				vim.cmd.colorscheme("gruvbox")
			elseif active_theme == "nord" then
				vim.cmd.colorscheme("nord")
			else
				vim.cmd.colorscheme("catppuccin")
			end
		end,
	},
	-- buffer tabline (catppuccin highlights applied after theme loads)
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = {
				mode = "buffers",
				diagnostics = false,
				show_buffer_close_icons = false,
				show_close_icon = false,
				separator_style = "thin",
			},
		},
	},
	-- statusline
	{
		"nvim-lualine/lualine.nvim",
		lazy = false,
		priority = 999,
		dependencies = { "catppuccin/nvim" },
		config = function()
			local lualine_theme = "auto"
			if active_theme == "tokyonight" then
				lualine_theme = "tokyonight"
			elseif active_theme == "gruvbox" then
				lualine_theme = "gruvbox"
			elseif active_theme == "nord" then
				lualine_theme = "nord"
			end

			require("lualine").setup({
				options = {
					theme = lualine_theme,
					globalstatus = true,
					section_separators = "",
					component_separators = "|",
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff" },
					lualine_c = { { "filename", path = 1 } },
					lualine_x = { "filetype" },
					lualine_y = {},
					lualine_z = { "location" },
				},
			})
		end,
	},
	-- fancy cmdline + notifications
	{
		"folke/noice.nvim",
		dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
		opts = {
			presets = {
				bottom_search         = true,
				long_message_to_split = true,
			},
		},
	},
	{ "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = { enabled = false } },
	-- git signs in gutter
	{ "lewis6991/gitsigns.nvim", opts = {} },
	-- todo/fixme highlights
	{ "folke/todo-comments.nvim", opts = {} },
	-- which-key
	{
		"folke/which-key.nvim",
		opts = {
			win = {
				height = { min = 3, max = 8 },
			},
			spec = {
				{ "<leader>b", group = "Buffers" },
				{ "<leader>s", group = "Search" },
				{ "<leader>f", group = "Format" },
				{ "<leader>p", group = "Pins" },
				{ "<leader>c", group = "Code/Actions" },
				{ "<leader>r", group = "Rails" },
				{ "<leader>g", icon = { icon = "󰊢", color = "red" } },
				{ "gz",        group = "Surround" },
				{ "[",         group = "Prev" },
				{ "]",         group = "Next" },
				{ "a",         group = "Around", mode = { "o", "x" } },
				{ "i",         group = "Inside", mode = { "o", "x" } },
			},
		},
	},
}
