return {
    -- Colorschemes load on demand: lazy.nvim pulls one in when :colorscheme names it
    { "catppuccin/nvim", name = "catppuccin", lazy = true, opts = {} },
    { "folke/tokyonight.nvim", lazy = true },
    { "rebelot/kanagawa.nvim", lazy = true },
    { "ellisonleao/gruvbox.nvim", lazy = true },
    { "rose-pine/neovim", name = "rose-pine", lazy = true },
    { "navarasu/onedark.nvim", lazy = true },
    { "EdenEast/nightfox.nvim", lazy = true },
    { "sainnhe/everforest", lazy = true },
    { "Mofiqul/dracula.nvim", lazy = true },
    { "projekt0n/github-nvim-theme", lazy = true },
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
            win = { height = { min = 3, max = 8 } },
            spec = {
                { "<leader>s", group = "Search" },
                { "<leader>p", group = "Pins", icon = { icon = "󰐃", color = "cyan" } },
                { "<leader>t", group = "Toggle", hidden = true },
                { "<leader>`", hidden = true },
                { "gz", group = "Surround" },
                { "[", group = "Prev" },
                { "]", group = "Next" },
                { "a", group = "Around", mode = { "o", "x" } },
                { "i", group = "Inside", mode = { "o", "x" } },
            },
        },
    },
}
