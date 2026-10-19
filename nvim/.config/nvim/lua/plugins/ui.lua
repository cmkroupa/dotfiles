return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("catppuccin-macchiato")
        end,
    },
    {
        "akinsho/bufferline.nvim",
        version = "*",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            options = {
                mode = "buffers",
                diagnostics = false,
                show_buffer_close_icons = false,
                show_close_icon = false,
                separator_style = "thin",
            },
        },
    },
    {
        "nvim-lualine/lualine.nvim",
        opts = {
            options = {
                theme = "auto",
                globalstatus = true,
                section_separators = "",
                component_separators = "|",
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "branch", "diff" },
                lualine_c = { { "filename", path = 1 } },
                lualine_x = { "filetype" },
                lualine_y = {},
                lualine_z = { "location" },
            },
        },
    },
    {
        "rcarriga/nvim-notify",
        opts = {
            stages = "static",
            timeout = 3000,
            max_width = 60,
        },
        config = function(_, opts)
            local notify = require("notify")
            notify.setup(opts)
            vim.notify = notify
        end,
    },
    {
        "folke/which-key.nvim",
        opts = {
            preset = "helix",
            icons = { mappings = false }, -- plain words, no icons next to each key
            -- Only pop up after <leader>; g, z, [, ], registers etc. stay quiet
            triggers = { { "<leader>", mode = { "n", "x" } } },
            -- Hide plugin internals: only mappings with a description show
            filter = function(m)
                return m.desc and m.desc ~= ""
            end,
        },
    },
}
