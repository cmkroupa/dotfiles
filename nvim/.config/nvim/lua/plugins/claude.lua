return {
    {
        "coder/claudecode.nvim",
        dependencies = { "folke/snacks.nvim" },
        cmd = {
            "ClaudeCode",
            "ClaudeCodeFocus",
            "ClaudeCodeSelectModel",
            "ClaudeCodeAdd",
            "ClaudeCodeSend",
            "ClaudeCodeTreeAdd",
            "ClaudeCodeStatus",
            "ClaudeCodeStart",
            "ClaudeCodeStop",
            "ClaudeCodeOpen",
            "ClaudeCodeClose",
            "ClaudeCodeDiffAccept",
            "ClaudeCodeDiffDeny",
            "ClaudeCodeCloseAllDiffs",
        },
        keys = {
            { "<leader>a", "<cmd>ClaudeCode<cr>", mode = { "n", "x" }, desc = "Toggle Claude Code" },
        },
        opts = {
            terminal = {
                split_side = "right",
                split_width_percentage = 0.30,
            },
        },
    },
}
