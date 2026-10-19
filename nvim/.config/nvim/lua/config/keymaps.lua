local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<cr>")
map("n", "K", "<nop>")
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Plugins" })
map("n", "<leader>p", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Problems" })
map("n", "<leader>c", "gcc", { remap = true, desc = "Comment" })
map("x", "<leader>c", "gc", { remap = true, desc = "Comment" })
-- Fuzzy-search every described mapping: type "format", "comment", "search"...
map("n", "<leader>?", function()
    require("telescope.builtin").keymaps({
        modes = { "n", "x" },
        show_plug = false,
        filter = function(k)
            return k.desc and k.desc ~= ""
        end,
    })
end, { desc = "Keys" })
