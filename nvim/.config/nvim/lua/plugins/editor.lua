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
    -- Files: `-` opens the current folder as a plain list of names you edit like text; g? shows how
    {
        "stevearc/oil.nvim",
        lazy = false,
        keys = {
            { "<leader>e", "<cmd>Oil<cr>", desc = "Explore files (new, rename, move, delete)" },
        },
        opts = {
            columns = {}, -- just names, no icons
            -- Only deletes ask for confirmation; new files, renames and moves just happen
            skip_confirm_for_simple_edits = true,
            view_options = { show_hidden = true },
            keymaps = {
                q = "actions.close",
                ["g?"] = {
                    desc = "Help",
                    callback = function()
                        vim.lsp.util.open_floating_preview({
                            "Enter   open file or folder",
                            "-       up a folder",
                            "q       close",
                            "",
                            "o       new file: type a name",
                            "        end it with / for a folder",
                            "        a/b.c also creates folder a",
                            "dd      delete",
                            "cw      rename",
                            "dd, p   move: cut here, paste in another folder",
                            "",
                            ":w      apply changes (u undoes before that)",
                        }, "text", { border = "rounded", title = " files " })
                    end,
                },
            },
        },
    },
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
