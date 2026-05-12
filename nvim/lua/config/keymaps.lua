local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<cr>")

map("n", "<leader>|", "<C-w>v", { desc = "Split Right" })
map("n", "<leader>-", "<C-w>s", { desc = "Split Down" })
map("n", "<leader>l", "<cmd>Lazy<cr>",                        { desc = "Lazy" })
map("n", "<leader>d", "<cmd>Trouble diagnostics toggle<cr>",  { desc = "Diagnostics" })
