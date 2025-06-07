local M = {}

--- Default configuration for CodeCopy.
-- @field notify
M.defaults = {
	keymap = "<leader>cc",
	notify = false,
	include_file_path = false,
}
M.options = vim.deepcopy(M.defaults)

--- Sets up the config for CodeCopy.
function M.setup(opts)
	M.options = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), opts or {})
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

return M
