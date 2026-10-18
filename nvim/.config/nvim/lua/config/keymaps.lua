local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<cr>")
map("n", "K", "<nop>")
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })
map("n", "<leader>d", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics" })
map("n", "<leader>tc", "gcc", { remap = true, desc = "Toggle Comment" })
map("x", "<leader>tc", "gc", { remap = true, desc = "Toggle Comment" })
map("n", "<leader>`", function()
    require("config.theme").select()
end, { desc = "Theme Switcher" })
map("n", "<leader>?", function()
    require("which-key").show({ global = true })
end, { desc = "Key Reference" })

local logs = {
    lsp = function()
        return vim.lsp.log.get_filename()
    end,
    mason = function()
        return vim.fn.stdpath("log") .. "/mason.log"
    end,
    conform = function()
        return vim.fn.stdpath("log") .. "/conform.log"
    end,
}
vim.api.nvim_create_user_command("OpenLog", function(opts)
    if not logs[opts.args] then
        vim.notify("Usage: OpenLog " .. table.concat(vim.tbl_keys(logs), "|"), vim.log.levels.ERROR)
        return
    end
    vim.cmd.edit(vim.fn.fnameescape(logs[opts.args]()))
end, {
    nargs = 1,
    complete = function()
        return vim.tbl_keys(logs)
    end,
    desc = "Open a Neovim plugin/LSP log",
})

local _hl_ids = {}
map("v", "<leader>th", function()
    local s = vim.fn.getpos("v")
    local e = vim.fn.getpos(".")
    local sr, sc, er, ec = s[2], s[3], e[2], e[3]
    if sr > er or (sr == er and sc > ec) then
        sr, sc, er, ec = er, ec, sr, sc
    end
    local positions = {}
    for lnum = sr, er do
        local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1] or ""
        local cs = (lnum == sr) and sc or 1
        local ce = (lnum == er) and ec or #line
        if cs <= ce then
            positions[#positions + 1] = { lnum, cs, ce - cs + 1 }
        end
    end
    for i = 1, #positions, 8 do
        local chunk = {}
        for j = i, math.min(i + 7, #positions) do
            chunk[#chunk + 1] = positions[j]
        end
        _hl_ids[#_hl_ids + 1] = vim.fn.matchaddpos("Search", chunk)
    end
    vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx")
end, { desc = "Pin highlight" })
map("n", "<leader>th", function()
    for _, id in ipairs(_hl_ids) do
        pcall(vim.fn.matchdelete, id)
    end
    _hl_ids = {}
end, { desc = "Clear pinned highlights" })
