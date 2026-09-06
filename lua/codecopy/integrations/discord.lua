local M = {}

local options = require("codecopy.config").options

function M.build(data)
	local integration = data.selected_integration
	local payload_builder = {}
	local title = ""
	if data.message ~= "" then
		title = "### " .. data.message .. "\n"
	end
	if integration.embed then
		title = data.message
		payload_builder.embeds = {
			{
				title = title,
				author = {
					name = "",
					profile = "",
				},
			},
		}
		local name, profile = "", ""
		if integration.name and integration.name ~= "" then
			name = integration.name
			if integration.profile and integration.profile ~= "" then
				profile = integration.profile
			end
		else
			name = "Sent via CodeCopy.nvim"
			profile = "https://github.com/Zonric/codecopy.nvim"
		end

		payload_builder.embeds[1].author.name = name
		payload_builder.embeds[1].author.profile = profile

		if options.codecopy.code_fence then
			payload_builder.embeds[1].description = "```" .. data.file.lang .. "\n" .. data.codecopy .. "\n```"
		else
			payload_builder.embeds[1].description = data.codecopy
		end
		if (integration.filepath == nil and options.codecopy.include_file_path) or integration.filepath then
			local filepath = ""
			if options.codecopy.use_relpath then
				filepath = data.file.relpath
			else
				filepath = data.file.path
			end
			payload_builder.embeds[1].footer = {
				text = filepath,
			}
		end
	else
		local content = title
		if options.codecopy.code_fence then
			content = content .. "```" .. data.file.lang .. "\n" .. data.codecopy .. "\n```"
		else
			content = content .. data.codecopy
		end
		if (integration.filepath == nil and options.codecopy.include_file_path) or integration.filepath then
			local filepath = ""
			if options.codecopy.use_relpath then
				filepath = data.file.relpath
			else
				filepath = data.file.path
			end
			content = content .. "*" .. filepath .. "*"
		end
		payload_builder.content = content
	end

	local payload = vim.json.encode(payload_builder)

	return {
		cmd = { "curl", "-X", "POST", "-H", "Content-Type: application/json", "-d", payload, integration.url },
	}
end

function M.handle_response(result)
	local response = result.stdout or ""
	if response == "" or response == nil then
		if options.messages.notify or options.messages.debug then
			vim.notify("Payload sent successfully.", vim.log.levels.INFO, { title = "CodeCopy Sent:" })
		end
		return
	end

	local ok, decoded = pcall(vim.json.decode, response)
	if not ok or type(decoded) ~= "table" then
		vim.notify("Payload returned an invalid response.", vim.log.levels.ERROR, { title = "CodeCopy Integration Error: " })
	elseif decoded.message then
		vim.notify("Payload failed with message: \n    " .. decoded.message, vim.log.levels.ERROR, { title = "CodeCopy Integration Error: " })
	elseif options.messages.notify or options.messages.debug then
		vim.notify("Playload sent successfully.", vim.log.levels.INFO, { title = "CodeCopy Sent:" })
	end
end

return M
