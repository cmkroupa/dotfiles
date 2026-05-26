local servers = require("config.lsp_servers")

local all_lsp = vim.list_extend(vim.deepcopy(servers.mason_lsp), servers.extra_lsp)

return {
    { "williamboman/mason.nvim", opts = {} },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = { "williamboman/mason.nvim" },
        opts = { ensure_installed = servers.mason_tools },
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        opts = {
            ensure_installed = servers.mason_lsp,
            automatic_installation = { exclude = { "solargraph" } },
        },
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = { "williamboman/mason-lspconfig.nvim" },
        config = function()
            -- solargraph conflicts with ruby_lsp — keep it off
            vim.lsp.enable("solargraph", false)

            vim.lsp.config("ruby_lsp", {
                init_options = { formatter = "rubocop" },
            })
            vim.lsp.config("html", {})
            vim.lsp.config("cssls", {})
            vim.lsp.config("emmet_ls", {
                filetypes = { "html", "eruby", "css", "scss" },
            })
            vim.lsp.config("clangd", {
                cmd = {
                    "clangd",
                    "--fallback-style={BasedOnStyle: LLVM, IndentWidth: 4, UseTab: Never}",
                    "--header-insertion=never",
                },
            })
            vim.lsp.config("pyright", {})
            vim.lsp.config("gopls", {})
            vim.lsp.config("rust_analyzer", {})
            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = { "vim" },
                        },
                        workspace = {
                            checkThirdParty = false,
                        },
                        telemetry = {
                            enable = false,
                        },
                    },
                },
            })

            vim.lsp.enable(all_lsp)

            local map = vim.keymap.set

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

                    -- Go to definition
                    map("n", "gd", function()
                        require("telescope.builtin").lsp_definitions()
                    end, e("force", opts, { desc = "Go to Definition" }))

                    -- Go to declaration
                    map("n", "gD", vim.lsp.buf.declaration, e("force", opts, { desc = "Go to Declaration" }))

                    -- Go to implementation
                    map("n", "gi", function()
                        require("telescope.builtin").lsp_implementations()
                    end, e("force", opts, { desc = "Go to Implementation" }))

                    -- Go to references
                    map("n", "gr", function()
                        require("telescope.builtin").lsp_references()
                    end, e("force", opts, { desc = "Go to References" }))

                    -- Switch source/header for C/C++ or fallback to declaration
                    map("n", "gh", function()
                        local ft = vim.bo[args.buf].filetype
                        if ft == "c" or ft == "cpp" then
                            vim.cmd("ClangdSwitchSourceHeader")
                        else
                            vim.lsp.buf.declaration()
                        end
                    end, e("force", opts, { desc = "Switch Source/Header or Declaration" }))

                    -- Hover documentation
                    map("n", "K", vim.lsp.buf.hover, e("force", opts, { desc = "Hover Docs" }))

                    -- Diagnostics navigation
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
