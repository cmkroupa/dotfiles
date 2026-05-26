local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<cr>")

map("n", "<leader>l", "<cmd>Lazy<cr>",                        { desc = "Lazy" })
map("n", "<leader>d", "<cmd>Trouble diagnostics toggle<cr>",  { desc = "Diagnostics" })
