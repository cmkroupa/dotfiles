return {
    {
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                python = { "black" },
                rust   = { "rustfmt" },
                go     = { "gofmt" },
                lua    = { "stylua" },
                eruby  = function()
                    local ok, servers = pcall(require, "config.lsp_servers")
                    if ok and servers and servers.extra_lsp then
                        for _, v in ipairs(servers.extra_lsp) do
                            if v == "ruby_lsp" then
                                return { "htmlbeautifier" }
                            end
                        end
                    end
                    return {}
                end,
                -- .rb: handled by ruby_lsp BufWritePre autocmd in lsp.lua
            },
            formatters = {
                stylua = {
                    prepend_args = { "--indent-type", "Spaces", "--indent-width", "4" },
                },
                htmlbeautifier = {
                    command = vim.fn.expand("$HOME") .. "/.local/share/mise/installs/ruby/latest/bin/htmlbeautifier",
                },
            },
            format_on_save = function(bufnr)
                local ft = vim.bo[bufnr].filetype
                -- skip c/cpp (uncrustify), skip .rb (ruby_lsp autocmd handles it)
                if ft == "c" or ft == "cpp" or ft == "ruby" then return nil end
                return { timeout_ms = 5000, lsp_fallback = true }
            end,
        },
    },
    {
        "mfussenegger/nvim-lint",
        config = function()
            local lint = require("lint")
            lint.linters_by_ft = {
                python = { "ruff" },
                -- ruby diagnostics come from ruby_lsp (rubocop integrated)
            }
            vim.api.nvim_create_autocmd({ "BufWritePost" }, {
                callback = function()
                    lint.try_lint()
                end,
            })
        end,
    },
}
