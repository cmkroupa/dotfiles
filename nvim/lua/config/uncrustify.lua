local M = {}

local CFG = vim.fn.expand("~/.uncrustify.cfg")

local function run(lines, lang)
    local tmp = os.tmpname()
    local f = io.open(tmp, "w")
    f:write(table.concat(lines, "\n"))
    f:close()

    local cmd = "uncrustify -c " .. vim.fn.shellescape(CFG)
        .. " -l " .. lang
        .. " -f " .. vim.fn.shellescape(tmp)
        .. " 2>/dev/null"
    local out = vim.fn.system(cmd)
    os.remove(tmp)

    if not out or out == "" then
        vim.notify("uncrustify produced no output", vim.log.levels.ERROR)
        return nil
    end

    local result = vim.split(out, "\n", { plain = true })
    if result[#result] == "" then table.remove(result) end
    return result
end

function M.setup(lang)
    vim.keymap.set("v", "<leader>f", function()
        local s = vim.api.nvim_buf_get_mark(0, "<")[1]
        local e = vim.api.nvim_buf_get_mark(0, ">")[1]
        local lines = vim.api.nvim_buf_get_lines(0, s - 1, e, false)
        local result = run(lines, lang)
        if not result then return end
        vim.api.nvim_buf_set_lines(0, s - 1, e, false, result)
    end, { buffer = true, desc = "Format selection" })

    vim.keymap.set("n", "<leader>f", function()
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local result = run(lines, lang)
        if not result then return end
        vim.api.nvim_buf_set_lines(0, 0, -1, false, result)
    end, { buffer = true, desc = "Format file" })
end

return M
