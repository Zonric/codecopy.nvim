local M = {}

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

M.handle_response = function(data)
	-- a successful response doesnt't have a status code in the data. but there is an id
	-- TODO check if gist id is present
	local id = data[5]
	if id and string.match(id, "^[0-9]+$") then
		vim.notify("Payload sent successfully.", vim.log.levels.INFO, { title = "CodeCopy Info:" })
	else
		vim.notify("Payload failed", vim.log.levels.ERROR, { title = "CodeCopy Error:" })
	end
end

return M
