return {
    { "echasnovski/mini.trailspace",
        event = "BufWritePre",
        config = function()
            require("mini.trailspace").setup()
            vim.api.nvim_create_autocmd("BufWritePre", {
                callback = function() MiniTrailspace.trim() end,
            })
        end,
    },
    { "numToStr/Comment.nvim",  event = "InsertEnter", opts = {} },
    { "windwp/nvim-autopairs",  event = "InsertEnter", opts = {} },
    { "windwp/nvim-ts-autotag", ft = { "html", "eruby" }, opts = {} },
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        opts = {},
        keys = {
            { "s", function() require("flash").jump()              end, mode = { "n", "x", "o" }, desc = "Flash Jump" },
            { "S", function() require("flash").treesitter()        end, mode = { "n", "x", "o" }, desc = "Flash Treesitter" },
            { "r",     function() require("flash").remote()            end, mode = "o",               desc = "Flash Remote" },
            { "R",     function() require("flash").treesitter_search() end, mode = { "o", "x" },      desc = "Flash TS Search" },
            { "<c-s>", function() require("flash").toggle()            end, mode = "c",               desc = "Flash Search Toggle" },
        },
    },
}
