return {
    { "tpope/vim-rails",
        ft = { "ruby", "eruby" },
        config = function()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "ruby", "eruby" },
                callback = function(args)
                    local map = vim.keymap.set
                    local opts = { buffer = args.buf }
                    local e = function(desc) return vim.tbl_extend("force", opts, { desc = desc }) end
                    map("n", "<leader>ra", "<cmd>A<cr>",           e("Alternate"))
                    map("n", "<leader>rr", "<cmd>R<cr>",           e("Related"))
                    map("n", "<leader>rc", "<cmd>Econtroller<cr>", e("Controller"))
                    map("n", "<leader>rm", "<cmd>Emodel<cr>",      e("Model"))
                    map("n", "<leader>rv", "<cmd>Eview<cr>",       e("View"))
                    map("n", "<leader>ri", "<cmd>Emigration<cr>",  e("Migration"))
                end,
            })
        end,
    },
}
