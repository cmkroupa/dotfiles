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
            -- Stimulus only matters where data-controller attributes live
            vim.lsp.config("stimulus_ls", { filetypes = { "html", "eruby" } })
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

            -- Right-click a problem > "Fix error" applies the suggested fix for that line. Servers list
            -- the real fix first and "disable this rule" options after it, so take the first one.
            vim.api.nvim_create_user_command("FixError", function()
                local taken = false
                local row = vim.api.nvim_win_get_cursor(0)[1]
                vim.lsp.buf.code_action({
                    context = { only = { "quickfix" } },
                    range = { start = { row, 0 }, ["end"] = { row, #vim.api.nvim_get_current_line() } },
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

            -- Right-click menu: only these, in place of Neovim's default list
            pcall(vim.api.nvim_del_augroup_by_name, "nvim.popupmenu")
            vim.cmd([[
                aunmenu PopUp
                nnoremenu PopUp.Fix\ error <Cmd>FixError<CR>
                nnoremenu PopUp.Definition <Cmd>Telescope lsp_definitions<CR>
                nnoremenu PopUp.References <Cmd>Telescope lsp_references<CR>
                vnoremenu PopUp.Cut "+x
                vnoremenu PopUp.Copy "+y
                anoremenu PopUp.Paste "+gP
            ]])
        end,
    },
}
