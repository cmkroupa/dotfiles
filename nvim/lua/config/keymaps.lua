local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<cr>")

map("n", "<leader>|", "<C-w>v", { desc = "Split Right" })
map("n", "<leader>-", "<C-w>s", { desc = "Split Down" })
map("n", "<S-h>", "<cmd>bprev<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "<leader>l", "<cmd>Lazy<cr>",                        { desc = "Lazy" })
map("n", "<leader>d", "<cmd>Trouble diagnostics toggle<cr>",  { desc = "Diagnostics" })

-- Buffer management
map("n", "<leader>bo", "<cmd>%bd!|e#|bd#<cr>",  { desc = "Close Others" })
map("n", "<leader>bw", "<cmd>%bd!<cr>",          { desc = "Wipe All" })
map("n", "<leader>bx", function()
    vim.cmd("silent! %bd!")
    vim.cmd("silent! only")
    vim.fn.setqflist({})
    vim.cmd("nohlsearch")
end, { desc = "Full Reset" })
