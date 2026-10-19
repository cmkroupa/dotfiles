return {
    { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
    { "windwp/nvim-ts-autotag", ft = { "html" }, opts = {} },
    {
        "folke/flash.nvim",
        opts = {},
        keys = {
            {
                "<leader>j",
                function()
                    require("flash").jump()
                end,
                mode = { "n", "x" },
                desc = "Jump",
            },
        },
    },
}
