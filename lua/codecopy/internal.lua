local M = {}

function M.parse_env(filepath)
	local env = {}
	local file = io.open(filepath, "r")

	if file == nil then
		vim.notify("File not found: " .. filepath, vim.log.levels.WARN, { title = "CodeCopy Warnning:" })
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
