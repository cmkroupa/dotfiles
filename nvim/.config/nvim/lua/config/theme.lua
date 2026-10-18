-- Remembers the last colorscheme and mirrors it to Ghostty (applies on Ghostty's next config reload)
local state_file = vim.fn.stdpath("state") .. "/colorscheme"
local ghostty_file = vim.fn.expand("~/.config/ghostty/active_theme")

-- Neovim colorscheme -> Ghostty theme (names from `ghostty +list-themes`)
local ghostty_themes = {
    ["catppuccin-macchiato"] = "Catppuccin Macchiato",
    ["catppuccin-mocha"] = "Catppuccin Mocha",
    ["catppuccin-latte"] = "Catppuccin Latte",
    ["tokyonight-storm"] = "TokyoNight Storm",
    ["tokyonight-night"] = "TokyoNight Night",
    ["tokyonight-moon"] = "TokyoNight Moon",
    ["kanagawa-wave"] = "Kanagawa Wave",
    ["kanagawa-dragon"] = "Kanagawa Dragon",
    ["gruvbox"] = "Gruvbox Dark",
    ["rose-pine"] = "Rose Pine",
    ["rose-pine-moon"] = "Rose Pine Moon",
    ["nightfox"] = "Nightfox",
    ["carbonfox"] = "Carbonfox",
    ["everforest"] = "Everforest Dark Hard",
    ["dracula"] = "Dracula",
    ["github_dark"] = "GitHub Dark",
}

local M = {}

function M.setup()
    local ok, lines = pcall(vim.fn.readfile, state_file)
    if not pcall(vim.cmd.colorscheme, ok and lines[1] or "catppuccin-macchiato") then
        pcall(vim.cmd.colorscheme, "catppuccin-macchiato")
    end

    vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("UserTheme", { clear = true }),
        callback = function(args)
            vim.fn.writefile({ args.match }, state_file)
            if ghostty_themes[args.match] then
                pcall(vim.fn.writefile, { "theme = " .. ghostty_themes[args.match] }, ghostty_file)
            end
        end,
    })
end

-- Telescope previews each theme as you move and restores the original on Esc
function M.select()
    require("telescope.builtin").colorscheme({ enable_preview = true, ignore_builtins = true })
end

return M
