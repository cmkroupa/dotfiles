local formatters_by_ft = {
    c = { "clang_format" },
    cpp = { "clang_format" },
    cmake = { "cmake_format" },
    python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
    sh = { "shfmt" },
    bash = { "shfmt" },
    lua = { "stylua" },
    javascript = { "prettierd" },
}

for _, ft in ipairs({ "json", "jsonc", "html", "yaml", "markdown", "css", "typescript" }) do
    formatters_by_ft[ft] = { "prettierd" }
end

local linters_by_ft = {
    cmake = { "cmake_lint" },
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
        init = function()
            -- Format on paste (like VS Code): reformat just the pasted range
            local paste = vim.paste
            vim.paste = function(lines, phase)
                local ret = paste(lines, phase)
                if (phase == -1 or phase == 3) and vim.bo.buftype == "" and vim.bo.modifiable then
                    local buf = vim.api.nvim_get_current_buf()
                    vim.schedule(function()
                        if not vim.api.nvim_buf_is_valid(buf) then
                            return
                        end
                        local s = vim.api.nvim_buf_get_mark(buf, "[")[1]
                        local e = vim.api.nvim_buf_get_mark(buf, "]")[1]
                        if s < 1 or e < s or e > vim.api.nvim_buf_line_count(buf) then
                            return
                        end
                        local last = vim.api.nvim_buf_get_lines(buf, e - 1, e, false)[1] or ""
                        require("conform").format({
                            bufnr = buf,
                            async = true,
                            lsp_format = "fallback",
                            range = { start = { s, 0 }, ["end"] = { e, #last } },
                        })
                    end)
                end
                return ret
            end

            -- Format on type (LSP servers that support it)
            if vim.lsp.on_type_formatting then
                vim.lsp.on_type_formatting.enable()
            end
        end,
        keys = {
            {
                "<leader>=",
                function()
                    require("conform").format({ lsp_format = "fallback", timeout_ms = 5000 })
                end,
                desc = "Format",
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
