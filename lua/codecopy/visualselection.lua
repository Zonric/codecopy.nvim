local M = {}

local options = require("codecopy.config").options
local linecount = 0

local function get_visual_selection()
	local vimode = vim.fn.mode()
	-- local _, start_row, start_col, _ = unpack(vim.fn.getpos("'<"))
	-- local _, end_row, end_col, _ = unpack(vim.fn.getpos("'>"))
	-- 0 indexing adjustment
	local lines = { "" }
	local start_pos = vim.fn.getpos("v")
	local end_pos = vim.fn.getpos(".")
	local temp_pos = 0

	-- debug output
	if options.debug then
		vim.notify(
			"M: "
				.. vim.inspect(vimode)
				.. " | StartPos: "
				.. vim.inspect(start_pos)
				.. ", EndPos: "
				.. vim.inspect(end_pos),
			vim.log.levels.WARN,
			{ title = "CodeCopy Debug: " }
		)
	end

	-- Visual by Character or Line ( Bottom->Up linked Inversion )
	if vimode == "v" or "V" then
		-- check for and correct bottom up selection
		if start_pos[2] > end_pos[2] then
			temp_pos = start_pos[2]
			start_pos[2] = end_pos[2]
			end_pos[2] = temp_pos
			temp_pos = start_pos[3]
			start_pos[3] = end_pos[3]
			end_pos[3] = temp_pos
		end
	elseif vimode == "\22" then
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
	-- Now get buffer lines
	lines = vim.api.nvim_buf_get_lines(0, start_pos[2], end_pos[2], false)

	-- Mode selection trimming.
	if vimode == "v" then
		-- Visual by Character trim first line and last line
		lines[1] = string.sub(lines[1], start_pos[3])
		if #lines > 1 then
			lines[#lines] = string.sub(lines[#lines], 0, end_pos[3])
		end
	-- Visual by box selection (Check for shorter than end column position)
	elseif vimode == "\22" then
		-- Trim all lines to the vistual block
		for i, line in ipairs(lines) do
			local linelength = vim.fn.strdisplaywidth(line)
			-- Padding for lines over-cut by the slice
			if linelength < end_pos[3] then
				lines[i] = lines[i] .. string.rep(" ", end_pos[3] - linelength)
			end
			-- Time for the trim...
			lines[i] = string.sub(lines[i], start_pos[3], end_pos[3])
		end
	end
	linecount = #lines
	-- Debug output
	if options.debug then
		vim.notify("Lines: " .. vim.inspect(lines), vim.log.levels.WARN, { title = "CodeCopy Debug:" })
	end

	return table.concat(lines, "\n")
end

local function get_lang_by_ext(file_ext)
	return options.lang_map[file_ext] or ""
end

--- `copy()` gets your visual selection, fences it with simple
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
	local fname = vim.api.nvim_buf_get_name(0)
	local fext = vim.fn.fnamemodify(fname, ":e")
	local lang = get_lang_by_ext(fext)
	local text = ""
	if options.include_file_path then
		text = text .. "### " .. fname .. "\n\n"
	end
	if options.code_fence then
		text = text .. "```" .. lang  .. "\n"
	end
	text = text .. get_visual_selection()
	if options.code_fence then
		text = text .. "\n```"
	end

	-- set reg
	vim.fn.setreg("+", text)
	-- flush feedkeys or reg will be a step behind.
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<ESC>", true, false, true), "n", false)

	if options.notify then
		vim.notify(
			"Copied selection to clipboard [" .. linecount .. "]",
			vim.log.levels.INFO,
			{ title = "CodeCopy: Copied Successfuly." }
		)
	end
end

return M
