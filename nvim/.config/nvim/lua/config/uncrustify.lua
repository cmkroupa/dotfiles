local M = {}

local FALLBACK_CFG = vim.fn.expand("~/.config/uncrustify/core-uncrustify.cfg")

local function find_config()
    local root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")
    if root ~= "" then
        local project_cfg = root .. "/tests/uncrustify/core-uncrustify.cfg"
        if vim.fn.filereadable(project_cfg) == 1 then return project_cfg end
    end
    if vim.fn.filereadable(FALLBACK_CFG) == 1 then return FALLBACK_CFG end
    return nil
end

local function count_edge_blanks(lines)
    local leading = 0
    for _, l in ipairs(lines) do
        if l == "" then leading = leading + 1 else break end
    end
    local trailing = 0
    for i = #lines, 1, -1 do
        if lines[i] == "" then trailing = trailing + 1 else break end
    end
    return leading, trailing
end

local function run(lines, lang, cfg, frag)
    local leading, trailing = count_edge_blanks(lines)

    local tmp_in  = os.tmpname()
    local tmp_out = os.tmpname()
    local f = io.open(tmp_in, "w")
    f:write(table.concat(lines, "\n"))
    f:close()

    local cmd = "uncrustify -c " .. vim.fn.shellescape(cfg)
        .. " -l " .. lang
        .. (frag and " --frag" or "")
        .. " -f " .. vim.fn.shellescape(tmp_in)
        .. " -o " .. vim.fn.shellescape(tmp_out)
        .. " 2>/dev/null"
    vim.fn.system(cmd)
    local exit_code = vim.v.shell_error
    os.remove(tmp_in)

    if exit_code ~= 0 then
        pcall(os.remove, tmp_out)
        vim.notify("uncrustify: exited with code " .. exit_code, vim.log.levels.ERROR)
        return nil
    end

    local out_f = io.open(tmp_out, "r")
    if not out_f then
        vim.notify("uncrustify: no output file", vim.log.levels.ERROR)
        return nil
    end
    local result = {}
    for line in out_f:lines() do result[#result + 1] = line end
    out_f:close()
    os.remove(tmp_out)

    for i = 1, leading do table.insert(result, i, "") end
    for _ = 1, trailing do result[#result + 1] = "" end

    return result
end

function M.setup(lang)
    vim.keymap.set("v", "<leader>u", function()
        local cfg = find_config()
        if not cfg then vim.notify("uncrustify: config not found", vim.log.levels.ERROR); return end

        local s = vim.api.nvim_buf_get_mark(0, "<")
        local e = vim.api.nvim_buf_get_mark(0, ">")
        local lnum1, col1 = s[1], s[2]
        local lnum2, col2 = e[1], e[2]

        local all_lines = vim.api.nvim_buf_get_lines(0, lnum1 - 1, lnum2, false)
        all_lines[1] = all_lines[1]:sub(col1 + 1)
        all_lines[#all_lines] = all_lines[#all_lines]:sub(1, col2 + 1)

        local result = run(all_lines, lang, cfg, true)
        if not result then return end
        vim.api.nvim_buf_set_lines(0, lnum1 - 1, lnum2, false, result)
    end, { buffer = true, desc = "Uncrustify selection" })

    vim.keymap.set("n", "<leader>u", function()
        local cfg = find_config()
        if not cfg then vim.notify("uncrustify: config not found", vim.log.levels.ERROR); return end

        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local result = run(lines, lang, cfg, false)
        if not result then return end
        vim.api.nvim_buf_set_lines(0, 0, -1, false, result)
    end, { buffer = true, desc = "Uncrustify file" })
end

return M
