local servers = require("config.lsp_servers")

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
        -- Servers are enabled explicitly below, not every one Mason happens to have installed
        opts = { ensure_installed = servers.mason_lsp, automatic_enable = false },
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = { "williamboman/mason-lspconfig.nvim" },
        config = function()
            vim.lsp.config("emmet_ls", { filetypes = { "html" } })
            vim.lsp.config("htmx", { filetypes = { "html" } })
            vim.lsp.config("html", { init_options = { provideFormatter = false } })
            vim.lsp.config("clangd", {
                cmd = { "clangd", "--clang-tidy" },
            })
            -- shellcheck and shfmt already run through nvim-lint and conform
            vim.lsp.config("bashls", {
                settings = {
                    bashIde = {
                        shellcheckPath = "",
                        shfmt = { path = "" },
                    },
                },
            })
            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        diagnostics = { globals = { "vim" } },
                        workspace = { checkThirdParty = false },
                        telemetry = { enable = false },
                    },
                },
            })

            vim.lsp.enable(servers.mason_lsp)

            -- Drop Neovim's default gr* LSP maps so gr (references) fires without waiting
            for _, k in ipairs({ "grn", "grr", "gri", "grt" }) do
                pcall(vim.keymap.del, "n", k)
            end
            pcall(vim.keymap.del, { "n", "x" }, "gra")

            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local map = vim.keymap.set
                    local opts = { buffer = args.buf }
                    local ext = function(desc)
                        return vim.tbl_extend("force", opts, { desc = desc })
                    end

                    vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })

                    map("n", "gd", function()
                        require("telescope.builtin").lsp_definitions()
                    end, ext("Go to Definition"))
                    map("n", "gD", vim.lsp.buf.declaration, ext("Go to Declaration"))
                    map("n", "gi", function()
                        require("telescope.builtin").lsp_implementations()
                    end, ext("Go to Implementation"))
                    map("n", "gr", function()
                        require("telescope.builtin").lsp_references()
                    end, ext("Go to References"))
                    if vim.lsp.get_client_by_id(args.data.client_id).name == "clangd" then
                        map("n", "gh", "<cmd>LspClangdSwitchSourceHeader<cr>", ext("Switch Source/Header"))
                    end
                    map("n", "<leader>i", vim.lsp.buf.hover, ext("Hover Info"))
                    map("n", "<leader>ti", function()
                        vim.lsp.inlay_hint.enable(
                            not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }),
                            { bufnr = args.buf }
                        )
                    end, ext("Toggle Inlay Hints"))
                end,
            })
        end,
    },
}
