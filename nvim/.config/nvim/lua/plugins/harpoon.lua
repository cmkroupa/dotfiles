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
                { desc = "󰐃 Pin File" })
            map("n", "<leader>pp", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
                { desc = "󰮰 Menu" })
            -- quick jump to pins 1-4
            for i = 1, 4 do
                map("n", "<leader>p" .. i, function() harpoon:list():select(i) end,
                    { desc = "󰐃 Pin " .. i })
            end
        end,
    },
}
