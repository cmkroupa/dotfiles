local M = {}

local function find_config()
    return vim.fn.expand("~/.config/uncrustify/uncrustify.cfg")
end

local function run(lines, cfg)
    local lang = vim.bo.filetype == "cpp" and "CPP" or "C"
    local cmd  = "uncrustify -q -l " .. lang .. " -c " .. vim.fn.shellescape(cfg)
    local out  = vim.fn.system(cmd, table.concat(lines, "\n") .. "\n")
    if vim.v.shell_error ~= 0 then
        vim.notify("uncrustify: exited with code " .. vim.v.shell_error, vim.log.levels.ERROR)
        return nil
    end
    local result = {}
    for line in out:gmatch("([^\n]*)\n") do result[#result + 1] = line end
    if result[#result] == "" then result[#result] = nil end
    return result
end

local function common_indent(lines)
    local min_ind = nil
    for _, l in ipairs(lines) do
        if l:match("%S") then
            local ind = l:match("^(%s*)")
            if min_ind == nil or #ind < #min_ind then min_ind = ind end
        end
    end
    return min_ind or ""
end

local function strip_indent(lines, ind)
    return vim.tbl_map(function(l)
        return l:sub(#ind + 1)
    end, lines)
end

local function restore_indent(lines, ind)
    return vim.tbl_map(function(l)
        return l == "" and l or (ind .. l)
    end, lines)
end

function M.setup()
    vim.keymap.set("v", "<leader>u", function()
        local cfg = find_config()
        if not cfg then vim.notify("uncrustify: no config found", vim.log.levels.ERROR); return end
        local s   = vim.api.nvim_buf_get_mark(0, "<")
        local e   = vim.api.nvim_buf_get_mark(0, ">")
        local sel = vim.api.nvim_buf_get_lines(0, s[1] - 1, e[1], false)
        local ind = common_indent(sel)
        local result = run(strip_indent(sel, ind), cfg)
        if not result then return end
        vim.api.nvim_buf_set_lines(0, s[1] - 1, e[1], false, restore_indent(result, ind))
    end, { buffer = true, desc = "Uncrust Selection" })

    vim.keymap.set("n", "<leader>u", function()
        local cfg = find_config()
        if not cfg then vim.notify("uncrustify: no config found", vim.log.levels.ERROR); return end
        local lines  = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local result = run(lines, cfg)
        if not result then return end
        vim.api.nvim_buf_set_lines(0, 0, -1, false, result)
    end, { buffer = true, desc = "Uncrust File" })
end

return M
