local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<cr>")
map("n", "K", "<nop>")
map("v", "<leader>Y", '"+y', { desc = "Yank to system clipboard" })
map("n", "<leader>Y", '"+yy', { desc = "Yank line to system clipboard" })
map({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from system clipboard" })
map({ "n", "v" }, "<leader>P", '"+P', { desc = "Paste from system clipboard (before)" })
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })
map("n", "<leader>d", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics" })
map("n", "<leader>th", function() require("config.theme").select_theme() end, { desc = "Theme Switcher" })

map("n", "<leader>h", function()
    require("snacks").win({
        text = {
            "  Flash                        LSP Navigation",
            "  s        jump                gd   definition",
            "  S        treesitter jump     gD   declaration",
            "  r        remote (operator)   gi   implementation",
            "  R        TS search (op/vis)  gr   references",
            "  <C-s>    toggle in /search",
            "                               gh   source/header (C/C++)",
            "  Surround (gz)                <leader>i  hover info",
            "  gza  add                     [d / ]d  prev/next error",
            "  gzd  delete                  [d / ]d  prev/next error",
            "  gzr  replace                 <leader>th theme switcher",
            "",
            "  Text Objects                 Treesitter Moves",
            "  af/if  function              ]f / [f  next/prev function",
            "  ac/ic  class                 ]t / [t  next/prev class",
            "  aa/ia  argument",
        },
        title = " keys ",
        border = "rounded",
        width = 60,
        height = 16,
        style = "minimal",
        keys = { q = "close", ["<Esc>"] = "close" },
    })
end, { desc = "Key Reference" })
