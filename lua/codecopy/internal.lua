local M = {}
local options = require("codecopy.config").options

function M.parse_env(filepath)
	local env = {}
	local file = io.open(filepath, "r")

	if file == nil then
		if not options.messages.silent then
			vim.notify("File not found: " .. filepath, vim.log.levels.ERROR, { title = "CodeCopy Config Error:" })
		end
		return {}
	end

	for line in file:lines() do
		local key, value = string.match(line, "([^=]+)=(.*)")
		if key and value then
			env[key] = value
		end
	end

	file:close()
	return env
end

function M.import_env(filepath)
	local lines = vim.fn.readfile(vim.fn.expand(filepath))
	local json_str = table.concat(lines, "\n")
	local env = vim.fn.json_decode(json_str)

	return env
end

return M
