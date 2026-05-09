return {
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local harpoon = require("harpoon")
			harpoon:setup()

			local map = vim.keymap.set
			map("n", "<leader>ha", function()
				harpoon:list():add()
			end, { desc = "Harpoon add file" })
			map("n", "<leader>hh", function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end, { desc = "Harpoon menu" })
			map("n", "<C-1>", function()
				harpoon:list():select(1)
			end, { desc = "Harpoon file 1" })
			map("n", "<C-2>", function()
				harpoon:list():select(2)
			end, { desc = "Harpoon file 2" })
			map("n", "<C-3>", function()
				harpoon:list():select(3)
			end, { desc = "Harpoon file 3" })
			map("n", "<C-4>", function()
				harpoon:list():select(4)
			end, { desc = "Harpoon file 4" })
		end,
	},
}
