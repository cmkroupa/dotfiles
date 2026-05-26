local M = {}

local CFG = vim.fn.expand("~/.uncrustify.cfg")

local function run(lines, lang, line_offset, frag)
    if vim.fn.filereadable(CFG) == 0 then
        vim.notify("uncrustify: config not found at " .. CFG, vim.log.levels.ERROR)
        return nil
    end

    local tmp = os.tmpname()
    local f = io.open(tmp, "w")
    f:write(table.concat(lines, "\n"))
    f:close()

    local err_tmp = os.tmpname()
    local cmd = "uncrustify -c " .. vim.fn.shellescape(CFG)
        .. " -l " .. lang
        .. (frag and " --frag" or "")
        .. " -f " .. vim.fn.shellescape(tmp)
        .. " 2>" .. vim.fn.shellescape(err_tmp)
    local out = vim.fn.system(cmd)
    local exit_code = vim.v.shell_error
    os.remove(tmp)

    local ef = io.open(err_tmp, "r")
    local err_out = ef and ef:read("*a") or ""
    if ef then ef:close() end
    os.remove(err_tmp)

    if exit_code ~= 0 then
        local msg = (err_out ~= "" and err_out) or ("exited with code " .. exit_code)
        -- strip the noisy "Parsing: ..." line
        msg = msg:gsub("[^\n]*Parsing:[^\n]*\n?", "")
        -- remap temp file line numbers to real buffer line numbers
        msg = msg:gsub(vim.pesc(tmp) .. ":(%d+)", function(n)
            return "line " .. (tonumber(n) + line_offset)
        end)
        msg = vim.trim(msg)
        vim.notify("uncrustify: " .. (msg ~= "" and msg or "unknown error"), vim.log.levels.ERROR)
        return nil
    end

    if not out or out == "" then
        vim.notify("uncrustify: produced no output", vim.log.levels.ERROR)
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
        local result = run(lines, lang, s - 1, true)
        if not result then return end
        vim.api.nvim_buf_set_lines(0, s - 1, e, false, result)
    end, { buffer = true, desc = "Format selection" })

    vim.keymap.set("n", "<leader>f", function()
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local result = run(lines, lang, 0)
        if not result then return end
        vim.api.nvim_buf_set_lines(0, 0, -1, false, result)
    end, { buffer = true, desc = "Format file" })
end

return M
