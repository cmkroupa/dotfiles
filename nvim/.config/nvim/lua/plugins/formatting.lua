local prettier_filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "json",
    "jsonc",
    "css",
    "scss",
    "html",
    "yaml",
    "markdown",
}

local eslint_filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
}

local formatters_by_ft = {
    c = { "clang_format" },
    cmake = { "cmake_format" },
    cpp = { "clang_format" },
    go = { "goimports" },
    python = { "ruff_format" },
    ruby = { "rubocop" },
    eruby = { "erb_format" },
    rust = { "rustfmt" },
    sh = { "shfmt" },
    bash = { "shfmt" },
    java = { "google-java-format" },
    lua = { "stylua" },
}

for _, ft in ipairs(prettier_filetypes) do
    formatters_by_ft[ft] = { "prettierd" }
end

local linters_by_ft = {
    cmake = { "cmake_lint" },
    go = { "golangcilint" },
    python = { "ruff" },
    ruby = { "rubocop" },
    sh = { "shellcheck" },
    bash = { "shellcheck" },
    java = { "checkstyle" },
    lua = { "selene" },
    json = { "jsonlint" },
    css = { "stylelint" },
    scss = { "stylelint" },
    yaml = { "yamllint" },
    markdown = { "markdownlint-cli2" },
    eruby = { "erb_lint" },
    make = { "checkmake" },
}

for _, ft in ipairs(eslint_filetypes) do
    linters_by_ft[ft] = { "eslint_d" }
end

local function ruby_project_root(bufnr)
    local filename = vim.api.nvim_buf_get_name(bufnr)
    local start = filename ~= "" and vim.fs.dirname(filename) or vim.uv.cwd()
    if not start then return nil end
    return vim.fs.root(start, { "Gemfile", "gems.rb" })
end

local function ruby_command(bufnr)
    local root = ruby_project_root(bufnr)
    if root and vim.fn.executable("bundle") == 1 then
        return {
            command = "bundle",
            args = { "exec", "rubocop" },
            cwd = function(_, ctx)
                return vim.fs.root(ctx.dirname, { "Gemfile", "gems.rb" })
            end,
        }
    end
    return { command = "rubocop", args = {} }
end

local function rubocop_args(prefix)
    local args = vim.list_extend(prefix or {}, {
        "-a",
        "-f",
        "quiet",
        "--stderr",
        "$FILENAME",
    })
    return args
end

local function rubocop_lint_args(prefix)
    local args = vim.list_extend(prefix or {}, {
        "--format",
        "json",
        "--force-exclusion",
        "--stdin",
        function() return vim.api.nvim_buf_get_name(0) end,
    })
    return args
end

return {
    {
        "stevearc/conform.nvim",
        config = function()
            local conform = require("conform")
            conform.setup({
                formatters_by_ft = formatters_by_ft,
                format_on_save = {
                    timeout_ms = 30000,
                    lsp_format = "fallback",
                },
                notify_on_error = true,
                formatters = {
                    rubocop = function(bufnr)
                        local formatter = ruby_command(bufnr)
                        formatter.args = rubocop_args(formatter.args)
                        formatter.stdin = false
                        formatter.tmpfile_format = "conform.$RANDOM.$FILENAME"
                        formatter.exit_codes = { 0, 1 }
                        return formatter
                    end,
                    stylua = { prepend_args = { "--indent-type", "Spaces", "--indent-width", "4" } },
                },
            })

            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("UserManualFormatKeys", { clear = true }),
                pattern = { "c", "cpp" },
                callback = function(args)
                    vim.keymap.set("n", "<leader>u", function()
                        conform.format({ bufnr = args.buf, formatters = { "clang_format" }, timeout_ms = 5000 })
                    end, { buffer = args.buf, desc = "Format C/C++ buffer" })
                end,
            })
        end,
    },
    {
        "mfussenegger/nvim-lint",
        config = function()
            local lint = require("lint")
            local rubocop = lint.linters.rubocop

            lint.linters_by_ft = linters_by_ft
            lint.linters.rubocop = function()
                local linter = vim.deepcopy(rubocop)
                if ruby_project_root(0) then
                    linter.cmd = "bundle"
                    linter.args = rubocop_lint_args({ "exec", "rubocop" })
                    linter.cwd = ruby_project_root(0)
                else
                    linter.cmd = "rubocop"
                    linter.args = rubocop_lint_args()
                end
                return linter
            end
            vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
                group = vim.api.nvim_create_augroup("UserLintOnSave", { clear = true }),
                callback = function()
                    lint.try_lint()
                end,
            })
        end,
    },
}
