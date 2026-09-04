local M = {}

function M.import_env(filepath)
	local lines = vim.fn.readfile(vim.fn.expand(filepath))
	local json_str = table.concat(lines, "\n")
	local env = vim.json.decode(json_str)

	return env
end

return M
