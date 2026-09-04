local M = {}
local options = require("codecopy.config").options

local function fileExists(filepath)
	local file = io.open(filepath, "r")
	if file then
		file:close()
		return true
	else
		return false
	end
end

function M.import_env(filepath)
	if not options.env.enabled then
		return
	end
	filepath = vim.fn.expand(filepath)
	local env = nil
	if fileExists(filepath) then
		local lines = vim.fn.readfile(filepath)
		local json_str = table.concat(lines, "\n")
		env = vim.json.decode(json_str)
	else
		vim.notify("Env is enabled but " .. filepath .. " file doesnt exist.", vim.log.levels.WARN, { title = "CodeCopy Config Warning:" })
		options.env.enabled = false
	end
	return env
end

return M
