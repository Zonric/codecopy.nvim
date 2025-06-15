local M = {}

---Default configuration for CodeCopy.
---@class Config
---@field keymap string
---@field code_fence boolean
---@field notify boolean
---@field include_file_path boolean
---@field debug boolean
M.defaults = {
	keymap = "<leader>cc",
	codecopy = {
		code_fence = true,
		include_file_path = false,
		openui = false,
		gist_to_clipboard = false,
	},
	messages = {
		notify = false,
		debug = false,
	},
	env = {
		enabled = false,
		env_path = "$HOME/.config/codecopy/env.json",
	},
}
M.options = vim.deepcopy(M.defaults)

---Sets up the config for CodeCopy.
function M.setup(opts)
	M.options = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), opts or {})
end

---Toggles code fencing.
function M.toggle_code_fence()
	M.options.codecopy.code_fence = not M.options.codecopy.code_fence
	if not M.options.messages.silent then
		vim.notify("Code Fencing: " .. (M.options.codecopy.code_fence and "Enabled" or "Disabled"), vim.log.levels.INFO, { title = "CodeCopy Options:" })
	end
end

---Toggles the inclusion of the file location in the markdown.
function M.toggle_include_file_path()
	M.options.codecopy.include_file_path = not M.options.codecopy.include_file_path
	if not M.options.messages.silent then
		vim.notify("Include File Path: " .. (M.options.codecopy.include_file_path and "Enabled" or "Disabled"), vim.log.levels.INFO, { title = "CodeCopy Options:" })
	end
end

---Toggles the UI opening on a CodeCopy
function M.toggle_openui()
	M.options.codecopy.openui = not M.options.codecopy.openui
	if not M.options.messages.silent then
		vim.notify("Open UI on codecopy: " .. (M.options.codecopy.openui and "Enabled" or "Disabled"), vim.log.levels.INFO, { title = "CodeCopy Options:" })
	end
end

---Toggles the gist url to clipboard option.
function M.toggle_gist_to_clipboard()
	M.options.codecopy.gist_to_clipboard = not M.options.codecopy.gist_to_clipboard
	if not M.options.messages.silent then
		vim.notify("Gist to Clipboard: " .. (M.options.codecopy.gist_to_clipboard and "Enabled" or "Disabled"), vim.log.levels.INFO, { title = "CodeCopy Options:" })
	end
end

---Toggles the notification setting.
function M.toggle_notify()
	M.options.messages.notify = not M.options.messages.notify
	if not M.options.messages.silent then
		vim.notify("Notify: " .. (M.options.messages.notify and "Enabled" or "Disabled"), vim.log.levels.INFO, { title = "CodeCopy Options:" })
	end
end

---Toggles the debug notification.
function M.toggle_debug()
	M.options.messages.debug = not M.options.messages.debug
	if not M.options.messages.silent then
		vim.notify("Debug: " .. (M.options.messages.debug and "Enabled" or "Disabled"), vim.log.levels.INFO, { title = "CodeCopy Options:" })
	end
end

---Gets the environment variables from the env_path.
function M.get_env()
	local expanded_path = vim.fn.expand(M.options.env.env_path)
	if not M.options.messages.silent and M.options.messages.debug then
		vim.notify("Environment variables from " .. expanded_path, vim.log.levels.WARN, { title = "CodeCopy Loading:" })
	end
	if M.options.env.enabled then
		return require("codecopy.internal").parse_env(expanded_path)
	end
end

return M
