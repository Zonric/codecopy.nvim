local M = {}

local options = require("codecopy.config").options
local state = require("codecopy.state")

local linecount = 0

local function get_normalized_selection()
	local mode = state.data.selection.mode
	local start_pos = vim.fn.getpos("v")
	local end_pos = vim.fn.getpos(".")

	local start_row, start_col = start_pos[2], start_pos[3]
	local end_row, end_col = end_pos[2], end_pos[3]

	-- Visual by Character or Line ( Bottom->Up linked Inversion )
	if mode == "v" or mode == "V" then
		if start_row > end_row or (start_row == end_row and start_col > end_col) then
			start_row, end_row = end_row, start_row
			start_col, end_col = end_col, start_col
		end
	elseif mode == "\22" then
		if start_row > end_row then
			start_row, end_row = end_row, start_row
		end
		if start_col > end_col then
			start_col, end_col = end_col, start_col
		end
	end

	return {
		start_row = start_row - 1,
		start_col = start_col,
		end_row = end_row,
		end_col = end_col,
	}
end

local function get_visual_selection()
	local selection = state.data.selection
	local mode = vim.fn.mode()
	selection.mode = mode
	selection.pos = get_normalized_selection()

	-- debug output
	if not options.messages.silent and options.messages.debug then
		vim.notify(
			"Sel: ["
				.. selection.mode
				.. "]\n"
				.. "  StartPos: {"
				.. selection.pos.start_row
				.. ", "
				.. selection.pos.start_col
				.. "}\n"
				.. "  EndPos: {"
				.. selection.pos.end_row
				.. ", "
				.. selection.pos.end_col
				.. "}",
			vim.log.levels.DEBUG,
			{ title = "CodeCopy Debug: " }
		)
	end

	local lines = { "" }
	lines = vim.api.nvim_buf_get_lines(0, selection.pos.start_row, selection.pos.end_row, false)
	if #lines == 0 then
		return ""
	end

	-- Mode selection trimming.
	if mode == "v" then
		if #lines > 1 then
			-- Single-line selection: slice between start_col end_col
			lines[1] = string.sub(lines[1], selection.pos.start_col, selection.pos.end_col)
		else
			-- Mulit-line selection: trim first and last lines
			lines[1] = string.sub(lines[1], selection.pos.start_col)
			lines[#lines] = string.sub(lines[#lines], 1, selection.pos.end_col)
		end
	elseif state.data.selection.mode == "\22" then
		-- Visual block: slice col across all lines, with padding if necessary
		for i, line in ipairs(lines) do
			local len = vim.fn.strdisplaywidth(line)
			if len < selection.pos.end_col then
				line = line .. string.rep(" ", selection.pos.end_col - len)
			end
			lines[i] = string.sub(line, selection.pos.start_col, selection.pos.end_col)
		end
	end
	linecount = #lines
	-- Debug output
	if not options.messages.silent and options.messages.debug then
		vim.notify("Lines: " .. vim.inspect(lines), vim.log.levels.DEBUG, { title = "CodeCopy Debug:" })
	end

	return table.concat(lines, "\n")
end

--- `copy()` gets your selection, fences it with simple
-- markdown codeblocks adds the lang based on the file ext,
-- and sets it to register '+'.
-- Uses: `vim.fn.setreg()`. See `:h registers`
-- Example:
-- A visual selection in `some/file.lua`:
-- ````
-- local function foo()
--     foo = "bar"
-- end
-- ````
-- Gets set in clipboard as:
-- ````
-- ```lua
-- local function foo()
--     foo = "bar"
-- end
-- ```
-- ````
function M.copy()
	local cwd = vim.fs.normalize(vim.fn.getcwd())
	local path = vim.fs.normalize(vim.api.nvim_buf_get_name(0))
	state.data.file.path = path

	local relpath = vim.fs.normalize(vim.fs.relpath(cwd, path))
	state.data.file.relpath = relpath

	local name = vim.fs.basename(path)
	state.data.file.name = name

	local ext = vim.fs.ext(name)
	state.data.file.ext = ext

	local lang = vim.filetype.match({ filename = name }) or "text"
	state.data.file.lang = lang

	state.data.codecopy = get_visual_selection()
	local clipboard = ""
	if options.codecopy.code_fence then
		clipboard = clipboard .. "```" .. state.data.file.lang .. "\n"
	end
	clipboard = clipboard .. state.data.codecopy
	if options.codecopy.code_fence then
		clipboard = clipboard .. "\n```"
	end

	-- set state.data.codecopy state
	-- state.data.codecopy = codecopy
	-- set systemclipboard setreg('+') = codecopy
	vim.fn.setreg("+", clipboard)
	-- flush feedkeys or reg will be a step behind.
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<ESC>", true, false, true), "n", false)

	if not options.messages.silent and (options.messages.notify or options.messages.debug) then
		vim.notify("Copied [" .. linecount .. "] lines.", vim.log.levels.INFO, { title = "CodeCopy: Copied Successfuly." })
	end
	if options.codecopy.openui then
		require("codecopy.ui").open()
	end
end

return M
