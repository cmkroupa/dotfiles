return {
    { "williamboman/mason.nvim", opts = {} },
    {
        "kosayoda/nvim-lightbulb",
        event = { "BufReadPost", "BufNewFile" },
        opts = { autocmd = { enabled = true } },
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = { "williamboman/mason.nvim" },
        opts = {
            ensure_installed = {
                "black", "ruff",   -- python
                "rubocop",         -- ruby (formatter + linter)
                "stylua",          -- lua
                "clang-format",    -- c/cpp
            },
        },
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        opts = {
            ensure_installed = {
                -- Web (ERB templates, HTML, CSS)
                "html",
                "cssls",
                "emmet_ls",
                -- C / C++
                "clangd",
                -- Python, Go, Rust, Lua
                "pyright",
                "gopls",
                "rust_analyzer",
                "lua_ls",
            },
            automatic_installation = { exclude = { "solargraph" } },
        },
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = { "williamboman/mason-lspconfig.nvim" },
        config = function()
            -- solargraph is installed in Mason but conflicts with ruby_lsp — keep it off
            vim.lsp.enable("solargraph", false)

            -- Ruby / Rails: ruby_lsp owns formatting (auto-detects bundle exec rubocop)
            vim.lsp.config("ruby_lsp", {
                init_options = { formatter = "rubocop" },
            })
            -- Web
            vim.lsp.config("html", {})
            vim.lsp.config("cssls", {})
            vim.lsp.config("emmet_ls", {
                filetypes = { "html", "eruby", "css", "scss" },
            })
            -- C / C++
            vim.lsp.config("clangd", {
                cmd = {
                    "clangd",
                    "--fallback-style={BasedOnStyle: LLVM, IndentWidth: 4, UseTab: Never}",
                    "--header-insertion=never",
                },
            })
            -- Others
            vim.lsp.config("pyright", {})
            vim.lsp.config("gopls", {})
            vim.lsp.config("rust_analyzer", {})
            vim.lsp.config("lua_ls", {})

            vim.lsp.enable({
                "ruby_lsp",
                "html",
                "cssls",
                "emmet_ls",
                "clangd",
                "pyright",
                "gopls",
                "rust_analyzer",
                "lua_ls",
            })

            local map = vim.keymap.set
            map("n", "gh", vim.lsp.buf.declaration, { desc = "Declaration (header)" })
            map("n", "gr", function()
                require("telescope.builtin").lsp_references()
            end, { desc = "References" })
            map("n", "gC", function()
                require("telescope.builtin").lsp_definitions()
            end, { desc = "Definition (implementation)" })
            map("n", "K", vim.lsp.buf.hover, { desc = "Hover Docs" })

            -- Format .rb files on save via ruby_lsp (handles bundle exec rubocop automatically)
            -- .erb uses htmlbeautifier via conform (ruby_lsp doesn't format ERB yet)
            vim.api.nvim_create_autocmd("BufWritePre", {
                callback = function(args)
                    if vim.bo[args.buf].filetype == "ruby" then
                        vim.lsp.buf.format({ name = "ruby_lsp", timeout_ms = 5000, bufnr = args.buf })
                    end
                end,
            })

            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local opts = { buffer = args.buf }
                    local e = vim.tbl_extend
                    map("n", "<leader>cr", vim.lsp.buf.rename,        e("force", opts, { desc = "Rename" }))
                    map("n", "<leader>ca", vim.lsp.buf.code_action,   e("force", opts, { desc = "Code Action" }))
                    map("n", "[d", vim.diagnostic.goto_prev, e("force", opts, { desc = "Prev Error" }))
                    map("n", "]d", vim.diagnostic.goto_next, e("force", opts, { desc = "Next Error" }))
                end,
            })
        end,
    },
    {
        "p00f/clangd_extensions.nvim",
        ft = { "c", "cpp" },
        opts = {},
    },
}
