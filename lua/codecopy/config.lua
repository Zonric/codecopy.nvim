local M = {}

--- Default configuration for CodeCopy.
-- @field keymap string
-- @field code_fence boolean
-- @field notify boolean
-- @field include_file_path boolean
-- @field debug boolean
M.defaults = {
	keymap = "<leader>cc",
	code_fence = true,
	notify = false,
	include_file_path = false,
	debug = false,
}
M.options = vim.deepcopy(M.defaults)

--- Sets up the config for CodeCopy.
function M.setup(opts)
	M.options = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), opts or {})
end

--- Toggles code fencing.
-- Flips `config.code_fence` between true and false.
function M.toggle_code_fence()
	M.options.code_fence = not M.options.code_fence
	vim.notify("Code Fencing: " .. (M.options.code_fence and "Enabled" or "Disabled"), vim.log.levels.INFO, { title = "CodeCopy Options:" })
end

--- Toggles the notification setting.
-- Flips `config.notify` between true and false.
function M.toggle_notify()
	M.options.notify = not M.options.notify
	vim.notify("Notify: " .. (M.options.notify and "Enabled" or "Disabled"), vim.log.levels.INFO, { title = "CodeCopy Options:" })
end

--- Toggles the inclusion of the file location in the markdown.
-- Flips `config.include_file_path` between true and false.
function M.toggle_include_file_path()
	M.options.include_file_path = not M.options.include_file_path
	vim.notify("Include File Path: " .. (M.options.include_file_path and "Enabled" or "Disabled"), vim.log.levels.INFO, { title = "CodeCopy Settings:" })
end

function M.toggle_debug()
	M.options.debug = not M.options.debug
	vim.notify("Debug: " .. (M.options.debug and "Enabled" or "Disabled"), vim.log.levels.INFO, { title = "CodeCopy Settings:" })
end

return M
