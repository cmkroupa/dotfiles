local formatters_by_ft = {
    c = { "clang_format" },
    cpp = { "clang_format" },
    cmake = { "cmake_format" },
    python = { "ruff_format" },
    sh = { "shfmt" },
    bash = { "shfmt" },
    lua = { "stylua" },
}

for _, ft in ipairs({ "json", "jsonc", "html", "yaml", "markdown" }) do
    formatters_by_ft[ft] = { "prettierd" }
end

local linters_by_ft = {
    cmake = { "cmake_lint" },
    python = { "ruff" },
    sh = { "shellcheck" },
    bash = { "shellcheck" },
    json = { "jsonlint" },
    yaml = { "yamllint" },
    markdown = { "markdownlint-cli2" },
    make = { "checkmake" },
}

return {
    {
        "stevearc/conform.nvim",
        event = "BufWritePre",
        cmd = "ConformInfo",
        keys = {
            {
                "<leader>u",
                function()
                    require("conform").format({ lsp_format = "fallback", timeout_ms = 5000 })
                end,
                desc = "Format buffer",
            },
        },
        opts = {
            formatters_by_ft = formatters_by_ft,
            format_on_save = {
                timeout_ms = 3000,
                lsp_format = "fallback",
            },
            formatters = {
                -- 4-space style unless the project has its own .clang-format
                clang_format = {
                    prepend_args = function(_, ctx)
                        if vim.fs.root(ctx.dirname, { ".clang-format", "_clang-format" }) then
                            return {}
                        end
                        return { "--style={BasedOnStyle: LLVM, IndentWidth: 4}" }
                    end,
                },
            },
        },
    },
    {
        "mfussenegger/nvim-lint",
        config = function()
            local lint = require("lint")
            lint.linters_by_ft = linters_by_ft
            vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
                group = vim.api.nvim_create_augroup("UserLintOnSave", { clear = true }),
                callback = function()
                    lint.try_lint()
                end,
            })
        end,
    },
}
