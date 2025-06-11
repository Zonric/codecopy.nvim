local M = {}
local options = require("codecopy.config").options or {
	messages = {
		debug = false,
		notify = false,
	}
}

function M.open()
	local filepath = vim.fn.getreg("p")
	local clipboard = vim.fn.getreg("+")

	local event = require("nui.utils.autocmd").event

	local NuiPopup = require("nui.popup")
	---@type { [string]: NuiPopup | nil }
	local codecopy_popups = {}

	local NuiLayout = require("nui.layout")
	---@type NuiLayout | nil
	local codecopy_window = nil

	-- setup the two buffer sections as NuiPopups and group them in table `codecopy_popups`
	codecopy_popups = {
		code_popup = NuiPopup({
			enter = true,
			focusable = true,
			border = {
				style = "rounded",
				text = {
					top = " CodeCopy Snippet Block ",
					top_align = "center",
				},
			},
			buf_options = { modifiable = true, readonly = false, },
		}),
		message_popup = NuiPopup({
			focusable = true,
			enter = true,
			border = {
				style = "single",
				text = {
					top = " Optional: Message ",
					top_align = "center",
				},
			},
			buf_options = {	modifiable = true, readonly = false, },
		})
	}
	-- Setup `window` or group of popups as NuiLayout
	codecopy_window = NuiLayout(
		{
			position = "50%",
			size = {
				width = 80,
				height = "60%",
			},
		},
		-- Attach popups to the layout
		NuiLayout.Box({
			NuiLayout.Box(codecopy_popups.code_popup, { size = "85%"}),
			NuiLayout.Box(codecopy_popups.message_popup, { size = "15%"}),
		},{ dir = "col" })
	)
	-- Open popups
	codecopy_window:mount()

	-- Setting buffer text.
	local code_buf_data = ""
	if options.include_file_path then
		code_buf_data = filepath
		code_buf_data = code_buf_data .. "\n" .. clipboard
	else
		code_buf_data = clipboard
	end
	vim.api.nvim_buf_set_lines(codecopy_popups.code_popup.bufnr, 0, -1, false, vim.split(code_buf_data, "\n"))

	local function _cleanup_()
		if options.messages.notify or options.messages.debug then
			vim.notify("Closing UI.", vim.log.levels.INFO, { title = "CodeCopy Info: "})
		end
		-- Unmount layout window if still mounted
		if codecopy_window ~= nil and codecopy_window._.mounted then
			codecopy_window:unmount()
		end

		-- Explicitly wipe & delete buffers
		for key, popup in pairs(codecopy_popups) do
			if type(popup.bufnr) == "number" and vim.api.nvim_buf_is_valid(popup.bufnr) then
				pcall(vim.api.nvim_buf_set_lines, popup.bufnr, 0, -1, false, {})
				pcall(vim.api.nvim_buf_delete, popup.bufnr, { force = true })
			end
			codecopy_popups[key] = nil
		end
		vim.schedule(function()
			codecopy_window = nil
		end)
	end

	local function _submit_()
		local codecopy_lines = vim.api.nvim_buf_get_lines(codecopy_popups.code_popup.bufnr, 0, -1, false)
		local message_lines = vim.api.nvim_buf_get_lines(codecopy_popups.message_popup.bufnr, 0, -1, false)
		local codecopy = table.concat(codecopy_lines, "\n")
		local message = "### " .. table.concat(message_lines, "\n")

		-- Set reg('+') = new_code
		vim.fn.setreg("+", codecopy)
		if options.messages.notify then
			vim.notify("Modified codecopy in clipboard.", vim.log.levels.INFO, { title = "CodeCopy Info:" })
		end
		if options.messages.debug then
			vim.print(message .. " | " .. codecopy)
		end
		-- CLEANUP AISLE 5!! unmount window, delete & buffers
		_cleanup_()
		require("codecopy.webhook").prep(message, codecopy)
	end

	-- Setting shared functionality of popups 
	for _, popup in pairs(codecopy_popups) do
		popup:on(event.BufWipeout, function()
			if codecopy_window == nil then return end
			vim.schedule(function()
				_cleanup_()
			end)
		end)
		popup:on(event.BufLeave, function()
			if codecopy_window == nil then return end
			vim.schedule(function()
				local curr_bufnr = vim.api.nvim_get_current_buf()
				for _, p in pairs(codecopy_popups) do
					if p.bufnr == curr_bufnr then
						return
					end
				end
				vim.schedule(function()
					_cleanup_()
				end)
			end)
		end)
		popup:map("n", "<ESC>", function()
			vim.schedule(function()
				_cleanup_()
			end)
		end, { noremap = true, desc = "Close CodeCopy UI." })
	end

	-- Maps for code_popup buffer
	codecopy_popups.code_popup:map("n", "<CR>", function()
		vim.api.nvim_set_current_win(codecopy_popups.message_popup.winid)
	end, { noremap = true, desc = "Focus message input." })
	codecopy_popups.code_popup:map("n", "<Tab>", function()
		vim.api.nvim_set_current_win(codecopy_popups.message_popup.winid)
	end, { noremap = true, desc = "Focus message input." })
	codecopy_popups.code_popup:map("i", "<C-Tab>", function()
		vim.api.nvim_set_current_win(codecopy_popups.message_popup.winid)
	end, { noremap = true, desc = "Focus message input." })

	-- Maps for message_popup buffer
	codecopy_popups.message_popup:map("n", "<Tab>", function()
		vim.api.nvim_set_current_win(codecopy_popups.code_popup.winid)
	end, { noremap = true, desc = "Focus message input." })
	codecopy_popups.message_popup:map("i", "<C-Tab>",function()
		vim.api.nvim_set_current_win(codecopy_popups.code_popup.winid)
	end, { noremap = true, desc = "Refocus Code window." })
	codecopy_popups.message_popup:map("i", "<CR>", function()
		_submit_()
	end, { noremap = true, desc = "Submit input." })
end

return M
