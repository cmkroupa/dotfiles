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

local function rubocop_args(prefix)
    local args = vim.list_extend(prefix or {}, {
        "--server",
        "-a",
        "-f",
        "quiet",
        "--stderr",
        "--stdin",
        "$FILENAME",
    })
    return args
end

local function rubocop_lint_args(prefix)
    local args = vim.list_extend(prefix or {}, {
        "--format",
        "json",
        "--force-exclusion",
        "--server",
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
                formatters = {
                    rubocop = function(bufnr)
                        if ruby_project_root(bufnr) then
                            return { command = "bundle", args = rubocop_args({ "exec", "rubocop" }), exit_codes = { 0, 1 } }
                        end
                        return { command = "rubocop", args = rubocop_args(), exit_codes = { 0, 1 } }
                    end,
                    stylua = { prepend_args = { "--indent-type", "Spaces", "--indent-width", "4" } },
                },
            })

            vim.api.nvim_create_autocmd("BufWritePre", {
                group = vim.api.nvim_create_augroup("UserFormatOnSave", { clear = true }),
                callback = function(args)
                    conform.format({ bufnr = args.buf, timeout_ms = 5000, lsp_format = "fallback" }, function(err)
                        if err then
                            local message = tostring(err):match("==> ERROR:%s*([^\n]+)")
                                or tostring(err):match("error:%s*([^\n]+)")
                                or tostring(err):gsub("\n.*", "")
                            vim.notify(message, vim.log.levels.ERROR, { title = "Format failed" })
                        end
                    end)
                end,
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
