return {
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-live-grep-args.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        },
        config = function()
            local telescope = require("telescope")
            telescope.setup({
                defaults = {
                    -- rg and fd already skip .gitignore'd files
                    vimgrep_arguments = {
                        "rg",
                        "--color=never",
                        "--no-heading",
                        "--with-filename",
                        "--line-number",
                        "--column",
                        "--smart-case",
                        "--hidden",
                        "--glob=!.git/",
                    },
                    path_display = { "truncate" },
                },
                extensions = { live_grep_args = { auto_quoting = true } },
            })
            telescope.load_extension("fzf")
            telescope.load_extension("live_grep_args")
        end,
        keys = {
            { "<leader>sf", "<cmd>Telescope find_files<cr>", desc = "Files" },
            { "<leader>sw", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Word" },
            { "<leader>sg", "<cmd>Telescope live_grep_args<cr>", desc = "Grep" },
            { "<leader>sb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
        },
    },
}
