vim.g.mapleader = " "

local map = vim.keymap.set

-- basics
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- splits
map("n", "<leader>sv", "<C-w>v", { desc = "Split vertical" })
map("n", "<leader>sh", "<C-w>s", { desc = "Split horizontal" })

-- buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

-- neo-tree
map("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "File tree" })

-- oil
map("n", "<leader>o", function()
	require("oil").open_float()
end, { desc = "Oil file manager" })

-- telescope
map("n", "<leader>ff", "<cmd>Telescope find_files cwd=~<cr>", { desc = "Find files (home)" })
map("n", "<leader>fg", "<cmd>Telescope live_grep cwd=~<cr>", { desc = "Live grep (home)" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Buffers" })
map("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", { desc = "LSP symbols" })
map("n", "<leader>fd", "<cmd>Telescope diagnostics<cr>", { desc = "Diagnostics" })

-- trouble
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics list" })
map("n", "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer diagnostics" })

-- git
map("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })

-- search/replace
map("n", "<leader>sr", "<cmd>Spectre<cr>", { desc = "Search & replace" })

-- ai
map("n", "<leader>ac", "<cmd>CodeCompanionChat<cr>", { desc = "AI chat" })
map("n", "<leader>ai", "<cmd>CodeCompanion<cr>", { desc = "AI inline" })
map("v", "<leader>ai", "<cmd>CodeCompanion<cr>", { desc = "AI inline (selection)" })
map("n", "<leader>at", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "AI chat toggle" })
