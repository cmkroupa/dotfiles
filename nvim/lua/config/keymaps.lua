local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<cr>")

map("n", "<leader>l", "<cmd>Lazy<cr>",                        { desc = "Lazy" })
map("n", "<leader>d", "<cmd>Trouble diagnostics toggle<cr>",  { desc = "Diagnostics" })

map("n", "<leader>tc", function()
    local ctx = require("treesitter-context")
    ctx.disable()
    vim.schedule(ctx.enable)
end, { desc = "Refresh treesitter context" })
