vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")
require("config.keymaps")
require("config.lazy")

-- Apply the user's persisted dynamic colorscheme choice
require("config.theme").apply_theme()


