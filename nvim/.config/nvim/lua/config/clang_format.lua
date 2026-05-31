local M = {}

local function find_style()
    local root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")
    if root ~= "" and vim.fn.filereadable(root .. "/tools/git_hooks/.clang-format") == 1 then
        return "file:" .. root .. "/tools/git_hooks/.clang-format"
    end
    return "file"
end

local function run(lines, style, filename, lnum1, lnum2)
    local cmd = "clang-format --style=" .. vim.fn.shellescape(style)
        .. " --assume-filename=" .. vim.fn.shellescape(filename)
        .. (lnum1 and (" --lines=" .. lnum1 .. ":" .. lnum2) or "")

    local out = vim.fn.system(cmd, table.concat(lines, "\n") .. "\n")

    if vim.v.shell_error ~= 0 then
        vim.notify("clang-format: exited with code " .. vim.v.shell_error, vim.log.levels.ERROR)
        return nil
    end

    local result = {}
    for line in out:gmatch("([^\n]*)\n") do result[#result + 1] = line end
    if result[#result] == "" then result[#result] = nil end
    return result
end

function M.setup()
    vim.keymap.set("v", "<leader>u", function()
        local s = vim.api.nvim_buf_get_mark(0, "<")
        local e = vim.api.nvim_buf_get_mark(0, ">")
        local all_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local result = run(all_lines, find_style(), vim.api.nvim_buf_get_name(0), s[1], e[1])
        if not result then return end
        vim.api.nvim_buf_set_lines(0, 0, -1, false, result)
    end, { buffer = true, desc = "clang-format selection" })

    vim.keymap.set("n", "<leader>u", function()
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local result = run(lines, find_style(), vim.api.nvim_buf_get_name(0), nil, nil)
        if not result then return end
        vim.api.nvim_buf_set_lines(0, 0, -1, false, result)
    end, { buffer = true, desc = "clang-format file" })
end

return M
