local M = {}

local function find_config()
    local root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")
    for _, name in ipairs({ "uncrustify.cfg", ".uncrustify.cfg" }) do
        if root ~= "" and vim.fn.filereadable(root .. "/" .. name) == 1 then
            return root .. "/" .. name
        end
    end
    local user_cfg = vim.fn.expand("~/dotfiles/uncrustify/uncrustify.cfg")
    if vim.fn.filereadable(user_cfg) == 1 then return user_cfg end
    return nil
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

function M.setup()
    vim.keymap.set("v", "<leader>u", function()
        local cfg = find_config()
        if not cfg then vim.notify("uncrustify: no config found", vim.log.levels.ERROR); return end
        local s   = vim.api.nvim_buf_get_mark(0, "<")
        local e   = vim.api.nvim_buf_get_mark(0, ">")
        local sel = vim.api.nvim_buf_get_lines(0, s[1] - 1, e[1], false)
        local result = run(sel, cfg)
        if not result then return end
        vim.api.nvim_buf_set_lines(0, s[1] - 1, e[1], false, result)
    end, { buffer = true, desc = "uncrustify selection" })

    vim.keymap.set("n", "<leader>u", function()
        local cfg = find_config()
        if not cfg then vim.notify("uncrustify: no config found", vim.log.levels.ERROR); return end
        local lines  = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local result = run(lines, cfg)
        if not result then return end
        vim.api.nvim_buf_set_lines(0, 0, -1, false, result)
    end, { buffer = true, desc = "uncrustify file" })
end

return M
