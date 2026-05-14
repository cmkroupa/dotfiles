return {
    {
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                python = { "black" },
                rust = { "rustfmt" },
                ruby = { "rubocop" },
                eruby = { "rubocop" },
                go = { "gofmt" },
                lua = { "stylua" },
            },
            formatters = {
                stylua = {
                    prepend_args = { "--indent-type", "Spaces", "--indent-width", "4" },
                },
            },
            format_on_save = function(bufnr)
                local ft = vim.bo[bufnr].filetype
                if ft == "c" or ft == "cpp" then return nil end
                return { timeout_ms = 2000, lsp_fallback = true }
            end,
        },
    },
    {
        "mfussenegger/nvim-lint",
        config = function()
            local lint = require("lint")
            lint.linters_by_ft = {
                python = { "ruff" },
                ruby = { "rubocop" },
            }
            vim.api.nvim_create_autocmd({ "BufWritePost" }, {
                callback = function()
                    lint.try_lint()
                end,
            })
        end,
    },
}
