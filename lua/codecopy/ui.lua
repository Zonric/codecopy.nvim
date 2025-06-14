local M = {}
local options = require("codecopy.config").options
local internal = require("codecopy.internal")
local state = require("codecopy.state")

local NuiLayout = require("nui.layout")
local NuiPopup = require("nui.popup")
local NuiMenu = require("nui.menu")
local event = require("nui.utils.autocmd").event

---Build a table of NuiMenu.items from a table of integrations defined by userconfig: env.json
---@param integrations any
---@return table NuiMenu.items
local function build_menu_items(integrations)
	local items = {}
	table.insert(items, NuiMenu.item("Clipboard", { target = "clipboard" }))
	if options.env.enabled then
		for _, entry in ipairs(integrations) do
			if type(entry) == "table" and entry.name and entry.target then
				table.insert(items, NuiMenu.item(entry.name, entry))
			else
				vim.notify("Invalid integration entry in evn.json: ".. vim.inspect(entry), vim.log.levels.WARN, { title = "CodeCopy Warning"})
			end
		end
	else
		table.insert(items, NuiMenu.item("Discord via Webhook", { target = "discord_wh" }))
	end
	return items
end

---Returns a string "Filepath" or "Filepath: Disabled"
---Used for UI decor.
---@return string
local function filepath_msg()
	return options.include_file_path and "Filepath:" or "Filepath: Disabled"
end

---Set buffers content
---@param bufnr integer
---@param lines string
local function set_lines(bufnr, lines)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(lines, "\n"))
end

---Get buffers content
---@param bufnr integer
---@param newline boolean?
---@return string
local function get_lines(bufnr, newline)
	newline = newline or false
	if newline then
		return table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
	else
		return table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
	end
end

---Unmounts and deletes UI state.
local function cleanup()
	if options.messages.debug then
		vim.notify("Closing UI.", vim.log.levels.INFO, { title = "CodeCopy Info: " })
	end
	-- Unmount layout window if still mounted
	if state.ui.layout ~= nil and state.ui.layout._.mounted then
		state.ui.layout:unmount()
	end
	-- Explicitly wipe & delete buffers
	for _, window in pairs(state.ui.sections) do
		if type(window.bufnr) == "number" and vim.api.nvim_buf_is_valid(window.bufnr) then
			pcall(vim.api.nvim_buf_set_lines, window.bufnr, 0, -1, false, "")
			pcall(vim.api.nvim_buf_delete, window.bufnr, { force = true })
		end
	end
	state.clear_ui()
end

---Sets up state.data and builds the final code snippet.
local function submit()
	state.data.file.path = get_lines(state.ui.sections.filepath_win.bufnr)
	state.data.file.name = vim.fn.fnamemodify(state.data.file.path, ":t")
	state.data.clipboard = get_lines(state.ui.sections.code_win.bufnr, true)
	state.data.message = get_lines(state.ui.sections.message_win.bufnr)

	local built_codecopy = ""
	if not (state.data.message == "") and not (state.data.message == nil) then
		built_codecopy = "# " .. state.data.message .. "\n\n"
	end
	built_codecopy = built_codecopy .. state.data.clipboard
	if options.include_file_path then
		built_codecopy = built_codecopy .."\n\n*"..state.data.file.path.."*"
	end

	state.data.clipboard = built_codecopy

	vim.fn.setreg("+", built_codecopy)
	if options.messages.notify then
		vim.notify("Modified codecopy in clipboard.", vim.log.levels.INFO, { title = "CodeCopy Info:" })
	end

	-- CLEANUP AISLE 5!! unmount window, delete & buffers
	cleanup()
	if state.data.selected_integration and state.data.selected_integration.target then
		vim.notify(vim.inspect(state.data.selected_integration.target))
	end
	require("codecopy.integration").dispatch()
end

---Builds the UI, Cleans and rebuilds if necessary.
---Sets state.ui
local function build_ui()
	cleanup()
	state.ui.sections.integrations_win = NuiMenu({
		enter = false,
		focusable = true,
		border = {
			style = "rounded",
			text = {
				top = " Integration ",
				top_align = "center",
			},
			position = "50%",
			size = { width = "30%", height = 20 },
		},
	}, {
		lines = build_menu_items(internal.import_env(options.env.env_path)),
		on_change = function(item)
			state.data.selected_integration = item
		end,
	})
	state.ui.sections.filepath_win = NuiPopup({
		enter = true,
		focusable = true,
		border = {
			style = "single",
			text = {
				top = filepath_msg(),
				top_align = "center",
			},
		},
		buf_options = { modifiable = true, readonly = false },
	})
	state.ui.sections.code_win = NuiPopup({
		enter = true,
		focusable = true,
		border = {
			style = "rounded",
			text = {
				top = " CodeCopy Snippet Block ",
				top_align = "center",
			},
		},
		buf_options = { modifiable = true, readonly = false },
	})
	state.ui.sections.message_win = NuiPopup({
		enter = true,
		focusable = true,
		border = {
			style = "single",
			text = {
				top = " Optional: Message ",
				top_align = "center",
			},
		},
		buf_options = { modifiable = true, readonly = false },
	})
	state.ui.layout = NuiLayout(
		{
			position = "50%",
			size = {
				width = 120,
				height = 40,
			},
		},
		NuiLayout.Box({
			NuiLayout.Box(state.ui.sections.integrations_win, { size = "30%" }),
			NuiLayout.Box({
				NuiLayout.Box(state.ui.sections.filepath_win, { size = "5%" }),
				NuiLayout.Box(state.ui.sections.code_win, { size = "85%" }),
				NuiLayout.Box(state.ui.sections.message_win, { size = "5%" }),
			}, { dir = "col", size = "70%" }),
		}, { dir = "row" })
	)
end

---Opens the UI, and sets buffers.
function M.open()
	if not next(state.data.file) then
		return
	end

	-- Set up menu items.
	local menu_items = {}
	local integrations = internal.import_env(options.env.env_path)
	for _, entry in ipairs(integrations) do
		table.insert(
			menu_items,
			NuiMenu.item(entry.name, {
				target = entry.target,
				token = entry.token,
			})
		)
	end

	if (not state.ui.layout) or (not next(state.ui.sections)) then
		build_ui()
	end

	-- Open popups
	state.ui.layout:mount()

	-- Build lines for code buffer
	local code_buffer_builder = ""
	if options.code_fence then
		code_buffer_builder = "```" .. state.data.file.lang .. "\n" .. state.data.codecopy .. "\n```"
	else
		code_buffer_builder = state.data.codecopy or ""
	end
	set_lines(state.ui.sections.code_win.bufnr, code_buffer_builder)
	-- Setting buffer text for filepath.
	if state.data.file.path ~= nil then
		set_lines(state.ui.sections.filepath_win.bufnr, state.data.file.path)
	end
	if (state.data.message ~= nil) and (state.data.message ~= "") then
		set_lines(state.ui.sections.message_win.bufnr, state.data.message)
	end

	-- vim.diagnostic.enable(false, { nil, state.ui.sections.code_win.bufnr })
	if options.code_fence then
		vim.bo[state.ui.sections.code_win.bufnr].filetype = "markdown"
		pcall(function()
			require("nvim-treesitter.highlight").attach(state.ui.sections.code_win.bufnr, "markdown")
		end)
	else
		vim.bo[state.ui.sections.code_win.bufnr].filetype = state.data.file.lang
		pcall(function()
			require("nvim-treesitter.highlight").attach(state.ui.sections.code_win.bufnr, state.data.file.lang)
		end)
	end

	local tab_order = {
		state.ui.sections.integrations_win.winid,
		state.ui.sections.filepath_win.winid,
		state.ui.sections.code_win.winid,
		state.ui.sections.message_win.winid,
	}
	-- Starting on state.ui.sections.message_popup
	local tab_index = 4
	vim.api.nvim_set_current_win(tab_order[tab_index])
	-- enter insert
	-- vim.cmd("startinsert")

	---Cycle focus to the next or previous window in the tab_order.
	---@param backward? boolean: (optional) if true, cycles backwards; otherwise, cycle forward
	local function _focus_next_(backward)
		if backward == nil then
			backward = false
		end
		if backward then
			tab_index = (tab_index - 2) % #tab_order + 1
		else
			tab_index = (tab_index % #tab_order) + 1
		end
		-- Set the focus to calculated index.
		vim.api.nvim_set_current_win(tab_order[tab_index])
	end

	-- Setting shared functionality of popups
	for _, popup in pairs(state.ui.sections) do
		popup:on(event.BufWipeout, function()
			if state.ui.layout == nil then
				return
			end
			vim.schedule(function()
				cleanup()
			end)
		end)
		popup:on(event.BufLeave, function()
			if state.ui.layout == nil then
				return
			end
			vim.schedule(function()
				local curr_bufnr = vim.api.nvim_get_current_buf()
				for _, p in pairs(state.ui.sections) do
					if p.bufnr == curr_bufnr then
						return
					end
				end
				vim.schedule(function()
					cleanup()
				end)
			end)
		end)
		popup:map("n", "<Tab>", _focus_next_, { noremap = true, desc = "Next UI section." })
		popup:map("n", "<ESC>", cleanup, { noremap = true, desc = "Close CodeCopy UI." })
	end

	-- Maps for integrations_menu
	state.ui.sections.integrations_win:map("n", "<CR>", function()
		vim.api.nvim_set_current_win(state.ui.sections.message_win.winid)
	end, { noremap = true, desc = "Focus message input." })

	-- Maps for code_popup buffer
	state.ui.sections.code_win:map("n", "<CR>", function()
		vim.api.nvim_set_current_win(state.ui.sections.message_win.winid)
	end, { noremap = true, desc = "Focus message input." })

	-- Maps for message_popup buffer
	state.ui.sections.message_win:map("n", "<CR>", function()
		submit()
	end, { noremap = true, desc = "Submit input." })
	state.ui.sections.message_win:map("i", "<CR>", function()
		submit()
	end, { noremap = true, desc = "Submit input." })
end

return M
