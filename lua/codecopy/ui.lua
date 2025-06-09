local M = {}
local options = require("codecopy.config").options

function M.create_float()
	require("codecopy.visualselection").copy()

	local win_width = 80
	local win_height = 40
	-- local win_row = opts.row or 2
	-- local win_col = opts.col or 10
	local win_row = 2 -- math.floor((vim.o.lines - win_height - 2) / 2)
	local win_col = 2 -- math.floor((vim.o.columns - win_width) / 2)

	local clipboard = vim.fn.getreg("+")
	local clipboard_lines = vim.split(clipboard, "\n")
	local code_buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(code_buf, 0, -1, false, clipboard_lines)
	local code_win = vim.api.nvim_open_win(code_buf, true, {
		relative = "editor",
		style = "minimal",
		border = "rounded",
		row = win_row,
		col = win_col,
		width = win_width,
		height = win_height,
	})

	local input_buf = vim.api.nvim_create_buf(false, true)
	local input_win = vim.api.nvim_open_win(input_buf, false, {
		relative = "editor",
		style = "minimal",
		border = "rounded",
		row = win_row + win_height + 2,
		col = win_col,
		width = win_width,
		height = 1,
	})

	vim.api.nvim_buf_set_lines(input_buf, 0, -1, false, {""})
	vim.api.nvim_set_current_win(input_win)

	vim.api.nvim_buf_set_keymap(input_buf, "n", "<CR>", "", {
		noremap = true,
		callback = function()
			local webhook_url = {}
			if options.env.enabled then
				webhook_url = require("codecopy.config").get_env().WEBHOOK_URL
			end
			local code_lines = vim.api.nvim_buf_get_lines(code_buf, 0, -1, false)
			local new_code = table.concat(code_lines, "\n")

			local input_text = table.concat(vim.api.nvim_buf_get_lines(input_buf, 0, -1, false), "\n")

			vim.fn.setreg("+", new_code)

			vim.api.nvim_win_close(code_win, true)
			vim.api.nvim_win_close(input_win, true)
			vim.api.nvim_buf_delete(code_buf, { force = true })
			vim.api.nvim_buf_delete(input_buf, { force = true })

			require("codecopy.webhook").send(webhook_url, input_text, new_code)

			if options.debug then
				vim.notify("Message: " .. input_text)
			end
		end,
		desc = "Submit and Hook the web..."
	})
end

return M
