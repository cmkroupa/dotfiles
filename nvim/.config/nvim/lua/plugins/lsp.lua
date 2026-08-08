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
            local html_template_filetypes = { "html", "templ", "gotmpl" }

            vim.filetype.add({
                extension = {
                    gohtml = "gotmpl",
                    gotmpl = "gotmpl",
                    tmpl = "gotmpl",
                    templ = "templ",
                },
                pattern = {
                    [".*%.html%.tmpl"] = "gotmpl",
                },
            })

            vim.lsp.config("emmet_ls", { filetypes = { "html", "css", "scss", "templ", "gotmpl" } })
            vim.lsp.config("html", {
                filetypes = { "html", "eruby", "templ", "gotmpl" },
                init_options = {
                    provideFormatter = false,
                },
            })
            vim.lsp.config("htmx", { filetypes = html_template_filetypes })
            vim.lsp.config("tailwindcss", {
                filetypes = {
                    "aspnetcorerazor",
                    "astro",
                    "astro-markdown",
                    "blade",
                    "clojure",
                    "django-html",
                    "htmldjango",
                    "edge",
                    "eelixir",
                    "elixir",
                    "ejs",
                    "erb",
                    "eruby",
                    "gohtml",
                    "gohtmltmpl",
                    "haml",
                    "handlebars",
                    "hbs",
                    "html",
                    "htmlangular",
                    "html-eex",
                    "heex",
                    "jade",
                    "leaf",
                    "liquid",
                    "markdown",
                    "mdx",
                    "mustache",
                    "njk",
                    "nunjucks",
                    "php",
                    "razor",
                    "slim",
                    "twig",
                    "css",
                    "less",
                    "postcss",
                    "sass",
                    "scss",
                    "stylus",
                    "sugarss",
                    "javascript",
                    "javascriptreact",
                    "reason",
                    "rescript",
                    "typescript",
                    "typescriptreact",
                    "vue",
                    "svelte",
                    "templ",
                    "gotmpl",
                },
            })
            vim.lsp.config("clangd", {
                root_markers = { "compile_commands.json" },
                cmd = { "clangd", "--background-index", "--clang-tidy", "--fallback-style=none" },
            })
            vim.lsp.config("bashls", {
                settings = {
                    bashIde = {
                        shellcheckPath = "",
                        shfmt = { path = "" },
                    },
                },
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
            vim.lsp.config("rust_analyzer", {
                settings = {
                    ["rust-analyzer"] = {
                        check = {
                            command = "clippy",
                        },
                    },
                },
            })
            vim.lsp.config("ruby_lsp", {
                init_options = {
                    formatter = "none",
                    linters = {},
                    addonSettings = {
                        ["Ruby LSP Rails"] = {
                            enablePendingMigrationsPrompt = false,
                        },
                    },
                },
            })

            vim.lsp.enable(servers.mason_lsp)

            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local map = vim.keymap.set
                    local opts = { buffer = args.buf }
                    local ext = function(desc) return vim.tbl_extend("force", opts, { desc = desc }) end

                    vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })

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
