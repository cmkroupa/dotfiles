local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<cr>")

map("n", "<leader>l", "<cmd>Lazy<cr>",                        { desc = "Lazy" })
map("n", "<leader>d", "<cmd>Trouble diagnostics toggle<cr>",  { desc = "Diagnostics" })

vim.api.nvim_create_user_command("LspRestart", function()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	for _, client in ipairs(clients) do
		vim.lsp.stop_client(client.id)
	end
	vim.defer_fn(function() vim.cmd("edit") end, 1000)
end, { desc = "Restart LSP for current buffer" })
