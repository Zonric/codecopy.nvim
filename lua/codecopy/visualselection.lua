local M = {}

local options = require("codecopy.config").options
local linecount = 0

local function get_visual_selection()
	local _, start_row, start_col, _ = unpack(vim.fn.getpos("'<"))
	local _, end_row, end_col, _ = unpack(vim.fn.getpos("'>"))
	-- 0 indexing adjustment
	start_row = start_row - 1

	local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row, false)
	if options.debug then
		vim.notify("{[" .. start_row .. ", " .. start_col .. "], [" .. end_row ..  "," .. end_col .. "]} : (" .. linecount .. ")", vim.log.levels.WARN, { title = "CodeCopy: DEBUG" })
	end
	linecount = #lines
	if #lines == 0 then
		if options.debug then
			vim.notify("Failed to get lines. {<" .. start_row .. ", " .. start_col .. ">, <".. end_row .. end_col .. ">} : (" .. linecount .. ")", vim.log.levels.ERROR, { title = "CodeCopy: DEBUG" })
		end
		return ""
	end

	lines[1] = string.sub(lines[1], start_col)
	if #lines > 1 then
		lines[#lines] = string.sub(lines[#lines], 1, end_col)
	end

	return table.concat(lines, "\n")
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
	local text = ""
	if options.include_file_path then
		text = text .. "### " .. fname .. "\n\n"
	end
	text = text .. "```" .. vim.fn.fnamemodify(fname, ":e") .. "\n"
	text = text .. get_visual_selection()
	text = text .. "\n```"

	-- set reg
	vim.fn.setreg("+", "")
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<ESC>", true, false, true), "n", false)
	vim.fn.setreg("+", text)
	-- flush feedkeys or reg will be a step behind.
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<ESC>", true, false, true), "n", false)

	if options.notify then
		vim.notify("Copied selection to clipboard [" .. linecount  .. "]", vim.log.levels.INFO, { title = "CodeCopy: Copied Successfuly." })
	end
end

return M
