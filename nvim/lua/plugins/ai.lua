return {
	{
		"git@github.com:cmkroupa/goloco.git",
		build = "cargo build --release",
		opts = {
			chat_model = "qwen2.5-coder:14b",
			embed_model = "nomic-embed-text",
			rag = "auto",
			auto_build = false,
			sidebar = {
				width = 60,
				side = "right",
			},
			keymaps_global = {
				n_toggle = "<leader>aa",
				n_chat = "<leader>ac",
				n_index = "<leader>ai",
				n_add_buffer = "<leader>ad",
				n_pick_pin = "<leader>aD",
				n_model = "<leader>am",
				n_rag_cycle = "<leader>ar",
				n_stop = "<leader>as",
				n_clear_chat = "<leader>ax",
				n_clear_pins = "<leader>ap",
				x_explain = "<leader>ae",
				x_ask = "<leader>aq",
				x_inline_edit = "<leader>ai",
				x_fix = "<leader>af",
			},
		},
	},
}
