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

	local payload = vim.fn.json_encode(payload_builder)

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

function M.handle_response(data)
	local check = #data or nil
	if check > 25 then
		local url = data[9]:match([["html_url": "([^"]+)"]])
		if options.codecopy.gist_to_clipboard then
			vim.fn.setreg("+", url)
			vim.notify("Payload sent and url copied to clipboard.", vim.log.levels.INFO, { title = "CodeCopy Info:" })
		else
			vim.notify("Payload sent successfully.", vim.log.levels.INFO, { title = "CodeCopy Info:" })
		end
	else
		vim.notify("Payload failed:\n    " .. data[2], vim.log.levels.ERROR, { title = "CodeCopy Error:" })
	end
end

return M
