local M = {}
local options = require("codecopy.config").options

---Builds the payload
function M.build(data)
	local integration = data.selected_integration
	local payload_builder = {
		description = data.message .. "\n",
		public = integration.public or false,
		files = {
			[data.file.name] = {
				content = data.codecopy,
			},
		},
	}

	local payload = vim.json.encode(payload_builder)

	return {
		cmd = {
			"curl",
			"-X",
			"POST",
			"-H",
			"Accept: application/vnd.github+json",
			"-H",
			"Authorization: Bearer " .. integration.token,
			"-H",
			"X-GitHub-Api-Version: 2022-11-28",
			"-d",
			payload,
			"https://api.github.com/gists",
		},
	}
end

function M.handle_response(result)
	local ok, response = pcall(vim.json.decode, result.stdout or "")
	if ok and type(response) == "table" and response.html_url then
		local url = response.html_url
		if options.codecopy.gist_to_clipboard then
			vim.fn.setreg("+", url)
			if options.messages.notify or options.messages.debug then
				vim.notify("Payload sent and url copied to clipboard.", vim.log.levels.INFO, { title = "CodeCopy Info:" })
			end
		else
			if options.messages.notify or options.messages.debug then
				vim.notify("Payload sent successfully.", vim.log.levels.INFO, { title = "CodeCopy Info:" })
			end
		end
	else
		local message = ok and type(response) == "table" and response.message or "Invalid response from Gist"
		vim.notify("Payload failed:\n    " .. message, vim.log.levels.ERROR, { title = "CodeCopy Error:" })
	end
end

return M
