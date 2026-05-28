return {
    { "adalessa/laravel.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
        ft = { "php", "blade" },
        config = function()
            require("laravel").setup()
        end,
    },
}
