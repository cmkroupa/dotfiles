vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

vim.diagnostic.config({
    update_in_insert = false,
    virtual_text     = { spacing = 2, prefix = "●" },
    signs            = true,
    underline        = true,
    severity_sort    = true,
    float            = { border = "rounded", source = true },
})
vim.cmd("runtime macros/matchit.vim")

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.colorcolumn = "120"


if vim.fn.has("wsl") == 1 then
    if vim.fn.executable("win32yank.exe") == 1 then
        vim.g.clipboard = {
            name = "win32yank",
            copy  = { ["+"] = "win32yank.exe -i --crlf", ["*"] = "win32yank.exe -i --crlf" },
            paste = { ["+"] = "win32yank.exe -o --lf",   ["*"] = "win32yank.exe -o --lf" },
            cache_enabled = 0,
        }
    else
        vim.g.clipboard = {
            name = "WslClipboard",
            copy  = { ["+"] = "clip.exe", ["*"] = "clip.exe" },
            paste = {
                ["+"] = 'powershell.exe -NoProfile -NonInteractive -c [Console]::Out.Write((Get-Clipboard -Raw).Replace("`r`n","`n").Replace("`r","`n"))',
                ["*"] = 'powershell.exe -NoProfile -NonInteractive -c [Console]::Out.Write((Get-Clipboard -Raw).Replace("`r`n","`n").Replace("`r","`n"))',
            },
            cache_enabled = 0,
        }
    end
end
