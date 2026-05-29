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

local _hl_ids = {}
map("v", "<leader>H", function()
    local s = vim.fn.getpos("v")
    local e = vim.fn.getpos(".")
    local sr, sc, er, ec = s[2], s[3], e[2], e[3]
    if sr > er or (sr == er and sc > ec) then sr, sc, er, ec = er, ec, sr, sc end
    local positions = {}
    for lnum = sr, er do
        local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1] or ""
        local cs = (lnum == sr) and sc or 1
        local ce = (lnum == er) and ec or #line
        if cs <= ce then positions[#positions + 1] = { lnum, cs, ce - cs + 1 } end
    end
    for i = 1, #positions, 8 do
        local chunk = {}
        for j = i, math.min(i + 7, #positions) do chunk[#chunk + 1] = positions[j] end
        _hl_ids[#_hl_ids + 1] = vim.fn.matchaddpos("Search", chunk)
    end
    vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx")
end, { desc = "Pin highlight" })
map("n", "<leader>H", function()
    for _, id in ipairs(_hl_ids) do pcall(vim.fn.matchdelete, id) end
    _hl_ids = {}
end, { desc = "Clear pinned highlights" })

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
            "  Surround (gz)                <leader>i   hover info",
            "  gza  add                     [d / ]d     prev/next error",
            "  gzd  delete                  <leader>ti  inlay hints",
            "  gzr  replace                 <leader>th  theme switcher",
            "                               <leader>H   pin/clear highlight",
            "",
            "  Text Objects                 Treesitter Moves",
            "  af/if  function              ]f / [f  next/prev function",
            "  ac/ic  class                 ]t / [t  next/prev class",
            "  aa/ia  argument",
        },
        title = " keys ",
        border = "rounded",
        width = 62,
        height = 17,
        style = "minimal",
        keys = { q = "close", ["<Esc>"] = "close" },
    })
end, { desc = "Key Reference" })
