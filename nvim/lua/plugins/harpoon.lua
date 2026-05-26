return {
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local harpoon = require("harpoon")
			harpoon:setup()

			local map = vim.keymap.set
			map("n", "<leader>pa", function() harpoon:list():add() end,
				{ desc = "Pin File" })
			map("n", "<leader>pp", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
				{ desc = "Menu" })
		end,
	},
}
