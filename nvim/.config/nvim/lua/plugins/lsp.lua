local servers = require("config.lsp_servers")

return {
    { "williamboman/mason.nvim", opts = {} },
    { "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = { "williamboman/mason.nvim" },
        opts = { ensure_installed = servers.mason_tools },
    },
    { "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        opts = { ensure_installed = servers.mason_lsp },
    },
    { "neovim/nvim-lspconfig",
        dependencies = { "williamboman/mason-lspconfig.nvim" },
        config = function()
            vim.lsp.config("emmet_ls", { filetypes = { "html", "css", "scss" } })
            vim.lsp.config("clangd", {
                root_markers = { "compile_commands.json" },
                cmd = { "clangd", "--background-index", "--fallback-style=none" },
            })
            vim.lsp.config("pyright", {
                settings = { python = { pythonPath = vim.fn.exepath("python") } },
            })
            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        diagnostics = { globals = { "vim" } },
                        workspace   = { checkThirdParty = false },
                        telemetry   = { enable = false },
                    },
                },
            })
            local ts_inlay_hints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
            }

            local function get_typescript_root_dir(fname)
                local monorepo_root = vim.fs.root(fname, {
                    "pnpm-workspace.yaml",
                    "pnpm-lock.yaml",
                    "yarn.lock",
                    "package-lock.json",
                    "bun.lockb",
                    "turbo.json",
                    "lerna.json",
                })
                if monorepo_root then
                    return monorepo_root
                end
                return vim.fs.root(fname, { "tsconfig.json", "package.json", ".git" })
            end

            vim.lsp.config("ts_ls", {
                root_dir = get_typescript_root_dir,
                settings = {
                    typescript = {
                        inlayHints = ts_inlay_hints,
                        preferences = {
                            preferGoToSourceDefinition = true,
                        },
                    },
                    javascript = {
                        inlayHints = ts_inlay_hints,
                        preferences = {
                            preferGoToSourceDefinition = true,
                        },
                    },
                },
            })

            vim.lsp.config("eslint", {
                settings = {
                    workingDirectory = { mode = "location" },
                },
            })

            vim.lsp.enable(servers.mason_lsp)

            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local map = vim.keymap.set
                    local opts = { buffer = args.buf }
                    local ext = function(desc) return vim.tbl_extend("force", opts, { desc = desc }) end

                    vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })

                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if client and client.name == "eslint" then
                        vim.api.nvim_create_autocmd("BufWritePre", {
                            buffer = args.buf,
                            command = "LspEslintFixAll",
                        })
                    end

                    for _, k in ipairs({ "grn", "gra", "grr", "gri" }) do
                        pcall(vim.keymap.del, "n", k, { buffer = args.buf })
                    end

                    map("n", "gd", function() require("telescope.builtin").lsp_definitions()    end, ext("Go to Definition"))
                    map("n", "gD", vim.lsp.buf.declaration,                                          ext("Go to Declaration"))
                    map("n", "gi", function() require("telescope.builtin").lsp_implementations() end, ext("Go to Implementation"))
                    map("n", "gr", function() require("telescope.builtin").lsp_references()      end, ext("Go to References"))
                    map("n", "gh", function()
                        local ft = vim.bo[args.buf].filetype
                        if ft == "c" or ft == "cpp" then vim.cmd("ClangdSwitchSourceHeader")
                        else vim.lsp.buf.declaration() end
                    end, ext("Switch Source/Header"))
                    map("n", "<leader>i",  vim.lsp.buf.hover, ext("Hover Info"))
                    map("n", "<leader>ti", function()
                        vim.lsp.inlay_hint.enable(
                            not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }),
                            { bufnr = args.buf }
                        )
                    end, ext("Toggle Inlay Hints"))
                    map("n", "[d", vim.diagnostic.goto_prev, ext("Prev Error"))
                    map("n", "]d", vim.diagnostic.goto_next, ext("Next Error"))
                end,
            })
        end,
    },
    { "p00f/clangd_extensions.nvim", ft = { "c", "cpp" }, opts = {} },
}
