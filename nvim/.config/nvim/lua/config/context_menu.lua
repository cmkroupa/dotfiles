local M = {}

function M.explain()
	local bufnr = vim.api.nvim_get_current_buf()
	local client = vim.lsp.get_clients({ bufnr = bufnr })[1]
	local encoding = client and client.offset_encoding or "utf-16"
	local params = vim.lsp.util.make_position_params(0, encoding)

	local results = { hover = nil, def = nil, done = 0 }

	local function show()
		if results.done < 2 then return end

		local float_buf = vim.api.nvim_create_buf(false, true)
		local md_lines = {}

		if results.hover and results.hover.contents then
			local converted = vim.lsp.util.convert_input_to_markdown_lines(results.hover.contents)
			for _, l in ipairs(converted) do
				table.insert(md_lines, l)
			end
		end

		local loc = results.def
		if type(loc) == "table" and loc[1] then loc = loc[1] end
		if loc and loc.uri then
			local path = vim.fn.fnamemodify(vim.uri_to_fname(loc.uri), ":~:.")
			local line_num = loc.range.start.line + 1
			local current = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":~:.")
			local def_str = path == current
				and ("Defined: line " .. line_num)
				or  ("Defined: " .. path .. ":" .. line_num)
			if #md_lines > 0 then table.insert(md_lines, "") end
			table.insert(md_lines, def_str)
		end

		if #md_lines == 0 then
			vim.notify("No info available", vim.log.levels.INFO)
			return
		end

		local styled = vim.lsp.util.stylize_markdown(float_buf, md_lines, {})

		local width = 0
		for _, l in ipairs(styled) do
			width = math.max(width, vim.fn.strdisplaywidth(l))
		end

		local win = vim.api.nvim_open_win(float_buf, false, {
			relative = "cursor", row = 1, col = 0,
			width = math.min(math.max(width + 2, 20), 100),
			height = math.max(#styled, 1),
			style = "minimal", border = "rounded",
		})

		vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter", "BufLeave" }, {
			once = true,
			callback = function() pcall(vim.api.nvim_win_close, win, true) end,
		})
	end

	vim.lsp.buf_request(bufnr, "textDocument/hover", params, function(_, result)
		results.hover = result
		results.done = results.done + 1
		vim.schedule(show)
	end)

	vim.lsp.buf_request(bufnr, "textDocument/definition", params, function(_, result)
		results.def = result
		results.done = results.done + 1
		vim.schedule(show)
	end)
end

vim.opt.mousemodel = "popup_setpos"

vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		for _, au in ipairs(vim.api.nvim_get_autocmds({ event = "MenuPopup" })) do
			pcall(vim.api.nvim_del_autocmd, au.id)
		end

		vim.cmd("silent! aunmenu PopUp")

		vim.cmd([[nmenu 10 PopUp.Explain      <cmd>lua require('config.context_menu').explain()<CR>]])
		vim.cmd([[imenu 10 PopUp.Explain      <cmd>lua require('config.context_menu').explain()<CR>]])

		vim.cmd([[amenu 20 PopUp.-Sep1-       :]])

		vim.cmd([[nmenu 30 PopUp.Paste        "+gP]])
		vim.cmd([[imenu 30 PopUp.Paste        <C-R><C-O>+]])
		vim.cmd([[vmenu 30 PopUp.Paste        "+gP]])

		vim.cmd([[nmenu 40 PopUp.Select\ All  ggVG]])
		vim.cmd([[imenu 40 PopUp.Select\ All  <C-O>gg<C-O>VG]])
		vim.cmd([[vmenu 40 PopUp.Select\ All  <Esc>ggVG]])

		vim.cmd([[amenu 50 PopUp.-Sep2-       :]])

		vim.cmd([[nmenu 60 PopUp.Inspect      <cmd>Inspect<CR>]])
	end,
})

return M
