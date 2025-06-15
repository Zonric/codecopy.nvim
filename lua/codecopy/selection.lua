local M = {}

local options = require("codecopy.config").options
local state = require("codecopy.state")

local linecount = 0

local function get_normalized_selection()
	local start_pos = vim.fn.getpos("v")
	local end_pos = vim.fn.getpos(".")
	local temp_pos = nil

	-- Visual by Character or Line ( Bottom->Up linked Inversion )
	if state.data.selection.mode == "v" or "V" then
		-- check for and correct bottom up selection
		if start_pos[2] > end_pos[2] then
			temp_pos = start_pos[2]
			start_pos[2] = end_pos[2]
			end_pos[2] = temp_pos
			temp_pos = start_pos[3]
			start_pos[3] = end_pos[3]
			end_pos[3] = temp_pos
		end
	elseif state.data.selection.mode == "\22" then
		-- Check for and correct bottom up selection
		if start_pos[2] > end_pos[2] then
			temp_pos = start_pos[2]
			start_pos[2] = end_pos[2]
			end_pos[2] = temp_pos
		end
		-- Check for and correct left to right selection
		if start_pos[3] > end_pos[3] then
			temp_pos = start_pos[3]
			start_pos[3] = end_pos[3]
			end_pos[3] = temp_pos
		end
	end
	-- 0 indexing adjustment
	start_pos[2] = start_pos[2] - 1

	return {
		start_row = start_pos[2],
		start_col = start_pos[3],
		end_row = end_pos[2],
		end_col = end_pos[3],
	}
end

local function get_visual_selection()
	local selection = require("codecopy.state").data.selection
	selection.mode = vim.fn.mode()
	selection.pos = get_normalized_selection()

	local lines = { "" }

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

	-- Now get buffer lines
	lines = vim.api.nvim_buf_get_lines(0, selection.pos.start_row, selection.pos.end_row, false)

	-- Mode selection trimming.
	if state.data.selection.mode == "v" then
		-- Visual by Character trim first line and last line
		lines[1] = string.sub(lines[1], selection.pos.start_col)
		if #lines > 1 then
			lines[#lines] = string.sub(lines[#lines], 0, selection.pos.end_col)
		end
	-- Visual by box selection (Check for shorter than end column position)
	elseif state.data.selection.mode == "\22" then
		-- Trim all lines to the vistual block
		for i, line in ipairs(lines) do
			local linelength = vim.fn.strdisplaywidth(line)
			-- Padding for lines over-cut by the slice
			if linelength < selection.pos.end_col then
				lines[i] = lines[i] .. string.rep(" ", selection.pos.end_col - linelength)
			end
			-- Time for the trim...
			lines[i] = string.sub(lines[i], selection.pos.start_col, selection.pos.end_col)
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
	state.data.file.path = vim.fn.fnamemodify(vim.trim(vim.api.nvim_buf_get_name(0)), ":p:.")
	state.data.file.name = vim.fn.fnamemodify(state.data.file.path, ":t")
	state.data.file.ext = vim.fn.fnamemodify(state.data.file.name, ":e")
	state.data.file.lang = vim.filetype.match({ filename = "file." .. state.data.file.ext }) or "text"
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
