local M = {}

M.theme_file = vim.fn.stdpath("config") .. "/active_theme.txt"
M.default_theme = "catppuccin-macchiato"

-- A curated list of 10 outstanding, premium modern colorschemes/flavors
M.themes = {
  "catppuccin-macchiato",
  "catppuccin-mocha",
  "catppuccin-latte",
  "tokyonight-storm",
  "tokyonight-night",
  "tokyonight-moon",
  "kanagawa-wave",
  "kanagawa-dragon",
  "gruvbox",
  "rose-pine",
  "rose-pine-moon",
  "onedark",
  "nightfox",
  "carbonfox",
  "everforest",
  "dracula",
  "github_dark",
}

-- Maps Neovim themes to Ghostty's built-in theme identifiers for seamless sync
function M.apply_ghostty_theme(theme_name)
  local map = {
    ["catppuccin-macchiato"] = "Catppuccin Macchiato",
    ["catppuccin-mocha"] = "Catppuccin Mocha",
    ["catppuccin-latte"] = "Catppuccin Latte",
    ["tokyonight-storm"] = "TokyoNight Storm",
    ["tokyonight-night"] = "TokyoNight",
    ["tokyonight-moon"] = "TokyoNight Moon",
    ["kanagawa-wave"] = "Kanagawa Wave",
    ["kanagawa-dragon"] = "Kanagawa Dragon",
    ["gruvbox"] = "GruvboxDark",
    ["rose-pine"] = "rose-pine",
    ["rose-pine-moon"] = "rose-pine-moon",
    ["onedark"] = "OneDark",
    ["nightfox"] = "nightfox",
    ["carbonfox"] = "carbonfox",
    ["everforest"] = "Everforest Dark Hard",
    ["dracula"] = "Dracula",
    ["github_dark"] = "GitHub Dark",
  }
  local ghostty_theme = map[theme_name] or "TokyoNight"
  local home = os.getenv("HOME")
  if home then
    local ghostty_file = home .. "/.config/ghostty/active_theme"
    local f = io.open(ghostty_file, "w")
    if f then
      f:write("theme = " .. ghostty_theme .. "\n")
      f:close()
    end
  end
end

-- Reads the active theme from the persistence file
function M.get_theme()
  local f = io.open(M.theme_file, "r")
  if f then
    local content = f:read("*all")
    f:close()
    content = vim.trim(content)
    if content ~= "" then
      return content
    end
  end
  return M.default_theme
end

-- Saves the active theme to the persistence file and syncs Ghostty
function M.set_theme(theme_name)
  local f = io.open(M.theme_file, "w")
  if f then
    f:write(theme_name)
    f:close()
  end
  M.apply_ghostty_theme(theme_name)
end

-- Safely applies the configured theme to both Neovim and Ghostty
function M.apply_theme()
  local theme = M.get_theme()
  pcall(vim.cmd, "colorscheme " .. theme)
  M.apply_ghostty_theme(theme)
end

-- Open Telescope to dynamically preview and select from the curated 10+ premium themes
function M.select_theme()
  local initial_theme = M.get_theme()
  local has_telescope, telescope = pcall(require, "telescope")

  if has_telescope then
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    local function preview_theme()
      local selection = action_state.get_selected_entry()
      if selection then
        pcall(vim.cmd, "colorscheme " .. selection[1])
        M.apply_ghostty_theme(selection[1])
      end
    end

    pickers.new({}, {
      prompt_title = "Theme Switcher (Preview with hjkl/Arrows, Enter to save, Esc to cancel)",
      finder = finders.new_table({
        results = M.themes,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        -- Press Enter to permanently select the theme
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          if selection then
            M.set_theme(selection[1])
            M.apply_theme()
            print("Theme changed to: " .. selection[1])
          else
            pcall(vim.cmd, "colorscheme " .. initial_theme)
            M.apply_ghostty_theme(initial_theme)
          end
        end)

        -- Cycle/Preview on cursor movement
        local function wrap_preview(action)
          return function()
            action(prompt_bufnr)
            preview_theme()
          end
        end

        map("i", "<Tab>", wrap_preview(actions.move_selection_next))
        map("i", "<S-Tab>", wrap_preview(actions.move_selection_previous))
        map("i", "<Down>", wrap_preview(actions.move_selection_next))
        map("i", "<Up>", wrap_preview(actions.move_selection_previous))
        map("i", "<C-n>", wrap_preview(actions.move_selection_next))
        map("i", "<C-p>", wrap_preview(actions.move_selection_previous))
        map("n", "j", wrap_preview(actions.move_selection_next))
        map("n", "k", wrap_preview(actions.move_selection_previous))
        map("n", "<Down>", wrap_preview(actions.move_selection_next))
        map("n", "<Up>", wrap_preview(actions.move_selection_previous))

        -- Press Esc / C-c to abort and restore original theme
        local function cancel()
          actions.close(prompt_bufnr)
          pcall(vim.cmd, "colorscheme " .. initial_theme)
          M.apply_ghostty_theme(initial_theme)
        end
        map("i", "<Esc>", cancel)
        map("n", "<Esc>", cancel)
        map("i", "<C-c>", cancel)

        return true
      end,
    }):find()
  else
    -- Fallback simple ui select if Telescope is not fully initialized
    vim.ui.select(M.themes, {
      prompt = "Select Colorscheme",
    }, function(choice)
      if choice then
        M.set_theme(choice)
        M.apply_theme()
      else
        pcall(vim.cmd, "colorscheme " .. initial_theme)
        M.apply_ghostty_theme(initial_theme)
      end
    end)
  end
end

return M
