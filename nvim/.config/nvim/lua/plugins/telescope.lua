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
            { "<leader>o", "<cmd>Telescope find_files<cr>", desc = "Open file" },
            { "<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Search this file" },
            { "<leader>s", "<cmd>Telescope live_grep_args<cr>", desc = "Search project" },
            { "<leader>b", "<cmd>Telescope buffers<cr>", desc = "Switch buffer" },
        },
    },
}
