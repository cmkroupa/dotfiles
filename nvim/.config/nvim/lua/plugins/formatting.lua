return {
    {
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                python = { "black" },
                lua = { "stylua" },
                javascript = { "prettierd" },
                javascriptreact = { "prettierd" },
                typescript = { "prettierd" },
                typescriptreact = { "prettierd" },
                json = { "prettierd" },
                jsonc = { "prettierd" },
                css = { "prettierd" },
                scss = { "prettierd" },
                html = { "prettierd" },
                yaml = { "prettierd" },
                markdown = { "prettierd" },
            },
            formatters = {
                stylua = { prepend_args = { "--indent-type", "Spaces", "--indent-width", "4" } },
            },
            format_on_save = function(bufnr)
                local ft = vim.bo[bufnr].filetype
                if ft == "c" or ft == "cpp" then
                    return nil
                end
                return { timeout_ms = 5000, lsp_format = "fallback" }
            end,
        },
    },
    {
        "mfussenegger/nvim-lint",
        config = function()
            local lint = require("lint")
            lint.linters_by_ft = { python = { "ruff" } }
            vim.api.nvim_create_autocmd("BufWritePost", {
                callback = function()
                    lint.try_lint()
                end,
            })
        end,
    },
}
