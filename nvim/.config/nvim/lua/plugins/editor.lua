local parsers = {
    "python",
    "c",
    "cpp",
    "lua",
    "vim",
    "vimdoc",
    "query",
    "html",
    "json",
    "yaml",
    "toml",
    "markdown",
    "markdown_inline",
    "bash",
    "make",
    "cmake",
}

-- nvim-treesitter-textobjects (main branch) has no keymap config; maps are set by hand
local select_maps = {
    af = { "@function.outer", "Around function" },
    ["if"] = { "@function.inner", "Inside function" },
    ac = { "@class.outer", "Around class" },
    ic = { "@class.inner", "Inside class" },
    aa = { "@parameter.outer", "Around argument" },
    ia = { "@parameter.inner", "Inside argument" },
}

local move_maps = {
    ["]f"] = { "goto_next_start", "@function.outer", "Next function" },
    ["]c"] = { "goto_next_start", "@class.outer", "Next class" },
    ["[f"] = { "goto_previous_start", "@function.outer", "Prev function" },
    ["[c"] = { "goto_previous_start", "@class.outer", "Prev class" },
}

return {
    {
        "echasnovski/mini.surround",
        opts = {
            mappings = {
                add = "ys",
                delete = "ds",
                replace = "cs",
                find = "gzf",
                find_left = "gzF",
                highlight = "gzh",
                update_n_lines = "gzn",
            },
        },
    },
    { "folke/trouble.nvim", opts = {} },
    { "christoomey/vim-tmux-navigator", lazy = false },
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").install(parsers)

            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true }),
                callback = function()
                    pcall(vim.treesitter.start)
                end,
            })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("nvim-treesitter-textobjects").setup({
                select = { lookahead = true },
                move = { set_jumps = true },
            })
            local select = require("nvim-treesitter-textobjects.select")
            for lhs, m in pairs(select_maps) do
                vim.keymap.set({ "x", "o" }, lhs, function()
                    select.select_textobject(m[1], "textobjects")
                end, { desc = m[2] })
            end
            local move = require("nvim-treesitter-textobjects.move")
            for lhs, m in pairs(move_maps) do
                vim.keymap.set({ "n", "x", "o" }, lhs, function()
                    move[m[1]](m[2], "textobjects")
                end, { desc = m[3] })
            end
        end,
    },
    { "j-hui/fidget.nvim", opts = {} },
}
