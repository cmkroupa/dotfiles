local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<cr>")
map("n", "K", "<nop>")
map("n", "<leader>l", "<cmd>Lazy<cr>",                       { desc = "Lazy" })
map("n", "<leader>d", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics" })

map("n", "<leader>h", function()
    local lines = {
        "  LSP                          Search",
        "  gd  definition               <leader>sf  files",
        "  gD  declaration              <leader>sg  grep",
        "  gi  implementation           <leader>sw  word in buffer",
        "  gr  references               <leader>sb  buffers",
        "  gh  source/header (C/C++)",
        "  <leader>i  hover info         Pins",
        "  [d  prev error               <leader>pa  pin file",
        "  ]d  next error               <leader>pp  menu",
        "                               <leader>p1-4  jump to pin",
        "  Motion",
        "  s   flash jump               Text Objects",
        "  S   flash treesitter         af/if  function",
        "                               ac/ic  class",
        "  Git                          aa/ia  argument",
        "  <leader>g  lazygit           ]f/[f  next/prev fn",
    }

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false

    local width = 0
    for _, l in ipairs(lines) do width = math.max(width, #l) end
    local win = vim.api.nvim_open_win(buf, false, {
        relative = "editor",
        row = math.floor((vim.o.lines - #lines) / 2),
        col = math.floor((vim.o.columns - width) / 2),
        width = width,
        height = #lines,
        style = "minimal",
        border = "rounded",
        title = " keys ",
        title_pos = "center",
    })
    vim.wo[win].winhl = "Normal:NormalFloat"

    vim.api.nvim_create_autocmd({ "CursorMoved", "BufLeave", "InsertEnter" }, {
        once = true,
        callback = function() pcall(vim.api.nvim_win_close, win, true) end,
    })
end, { desc = "Key Reference" })

vim.api.nvim_create_user_command("LspRestart", function()
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
        vim.lsp.stop_client(client.id)
    end
    vim.defer_fn(function() vim.cmd("edit") end, 1000)
end, { desc = "Restart LSP for current buffer" })
