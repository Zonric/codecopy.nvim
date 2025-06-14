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
	code_fence = true,
	include_file_path = false,
	openui = false,
	messages = {
		notify = false,
		debug = false,
	},
	env = {
		enabled = false,
		env_path = "$HOME/.config/codecopy/env.json",
	},
	webhook = {
		branding = false,
		embed = false,
		--author = {
			--name = "CodeCopy.nvim"
			--proile = "https://github.com/Zonric/CodeCopy.nvim"
		--},
		url = "",
	}
}
M.options = vim.deepcopy(M.defaults)

---Sets up the config for CodeCopy.
function M.setup(opts)
	M.options = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), opts or {})
end

---Toggles code fencing.
---Flips `config.code_fence` between true and false.
function M.toggle_code_fence()
	M.options.code_fence = not M.options.code_fence
	vim.notify("Code Fencing: " .. (M.options.code_fence and "Enabled" or "Disabled"), vim.log.levels.INFO, { title = "CodeCopy Options:" })
end

---Toggles the notification setting.
---Flips `config.notify` between true and false.
function M.toggle_notify()
	M.options.messages.notify = not M.options.messages.notify
	vim.notify("Notify: " .. (M.options.messages.notify and "Enabled" or "Disabled"), vim.log.levels.INFO, { title = "CodeCopy Options:" })
end

---Toggles the inclusion of the file location in the markdown.
---Flips `config.include_file_path` between true and false.
function M.toggle_include_file_path()
	M.options.include_file_path = not M.options.include_file_path
	vim.notify("Include File Path: " .. (M.options.include_file_path and "Enabled" or "Disabled"), vim.log.levels.INFO, { title = "CodeCopy Settings:" })
end

---Toggles the debug notification.
---Flips `config.messages.debug` between true and false.
function M.toggle_debug()
	M.options.messages.debug = not M.options.messages.debug
	vim.notify("Debug: " .. (M.options.messages.debug and "Enabled" or "Disabled"), vim.log.levels.INFO, { title = "CodeCopy Settings:" })
end

---Gets the environment variables from the env_path.
function M.get_env()
	local expanded_path = vim.fn.expand(M.options.env.env_path)
	if M.options.messages.debug then
		vim.notify("Environment variables from " .. expanded_path, vim.log.levels.WARN, { title = "CodeCopy Loading:" })
	end
	if M.options.env.enabled then
		return require("codecopy.internal").parse_env(expanded_path)
	end
end

return M
