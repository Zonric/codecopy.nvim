local M = {}

--- Default configuration for CodeCopy.
-- @field keymap string
-- @field code_fence boolean
-- @field notify boolean
-- @field include_file_path boolean
-- @field debug boolean
-- @field lang_map table
M.defaults = {
	keymap = "<leader>cc",
	code_fence = true,
	notify = false,
	include_file_path = false,
	debug = false,
	env = {
		enabled = false,
		env_path = "$HOME/.config/codecopy/env",
	},
	webhook = {
		url = "",
		author = {
			name = "",
			profile = "",
		},
	},
	lang_map = {
		["ahk"] = "ahk",
		["bash"] = "bash",
		["bat"] = "bat",
		["c"] = "c",
		["c++"] = "cpp",
		["cc"] = "cpp",
		["cmd"] = "bat",
		["cpp"] = "cpp",
		["css"] = "css",
		["cxx"] = "cpp",
		["diff"] = "diff",
		["go"] = "go",
		["h++"] = "cpp",
		["hh"] = "cpp",
		["hpp"] = "cpp",
		["htm"] = "html",
		["html"] = "html",
		["xhtml"] = "html",
		["hxx"] = "cpp",
		["ini"] = "ini",
		["java"] = "java",
		["js"] = "javascript",
		["lua"] = "lua",
		["md"] = "markdown",
		["patch"] = "diff",
		["py"] = "python",
		["rust"] = "rust",
		["sh"] = "bash",
		["ts"] = "typescript",
		["zsh"] = "zsh",
		["php"] = "php",
		["blade"] = "html",
		["text"] = "txt",
		["vim"] = "vim",
		["xml"] = "xml",
		["xsl"] = "xml",
		["yaml"] = "yaml",
		["yml"] = "yaml",
	},
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

function M.get_env()
	vim.print("CodeCopy: Getting environment variables from " .. M.options.env.env_path)
	if M.options.env.enabled then
		return require("codecopy.internal").parse_env(vim.fn.expand(M.options.env.env_path))
	end
end

return M
