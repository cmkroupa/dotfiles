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
            -- shfmt already runs through conform; shellcheck runs inside bashls so its fixes show up for Space f
            vim.lsp.config("bashls", {
                settings = { bashIde = { shfmt = { path = "" } } },
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

            -- Drop Neovim's default gr* LSP keys (rename, actions, ...): every command lives under Space
            for _, k in ipairs({ "grn", "grr", "gri", "grt" }) do
                pcall(vim.keymap.del, "n", k)
            end
            pcall(vim.keymap.del, { "n", "x" }, "gra")

            -- Space d: where is this defined; Space r: where is this used. Same in every language.
            -- In files with no language server they say so instead of doing nothing.
            local function picker(name)
                return function()
                    if #vim.lsp.get_clients({ bufnr = 0 }) == 0 then
                        vim.notify("No language server for this file", vim.log.levels.WARN)
                        return
                    end
                    require("telescope.builtin")[name]()
                end
            end
            vim.keymap.set("n", "<leader>d", picker("lsp_definitions"), { desc = "Definition" })
            vim.keymap.set("n", "<leader>r", picker("lsp_references"), { desc = "References" })

            -- Apply the suggested fix for the problem under the cursor. Servers list the real fix
            -- first and "disable this rule" options after it, so take the first one.
            vim.keymap.set("n", "<leader>f", function()
                local taken = false
                vim.lsp.buf.code_action({
                    context = { only = { "quickfix" } },
                    filter = function()
                        if taken then
                            return false
                        end
                        taken = true
                        return true
                    end,
                    apply = true,
                })
            end, { desc = "Fix error" })
        end,
    },
}
