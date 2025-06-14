local M = {}

function M.build(data)
	local options = require ("codecopy.config").options
	local integration = data.selected_integration
	local payload_builder = {}
	if integration.embed then
		payload_builder.embeds = {{
			title = data.message,
			author = {
				name = "",
				url = ""
			},
		}}
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
		table.insert(payload_builder.embeds[1].author, {
			name = name,
			profile = profile,
		})
		if options.code_fence then
			payload_builder.embeds[1].description = "```"..data.file.lang.."\n"..data.codecopy.."\n```"
		else
			payload_builder.embeds[1].description = data.codecopy
		end
		if options.include_file_path then
			payload_builder.embeds[1].footer = {
				text = data.file.path
			}
		end
	else
		local content = data.message .. "\n\n"
		if options.include_file_path then
			content = content .. data.file.path
		end
		if options.code_fence then
			content = content .. "```"..data.file.lang.."\n"..data.codecopy.."\n```"
		else
			content = content .. data.codecopy
		end
		if integration.branding then
			content = content .. "\n\nSent via [CodeCopy.nvim](https://github.com/Zonric/CodeCopy.nvim)"
		end
		payload_builder.content = content
	end

	local payload = vim.fn.json_encode(payload_builder)

	return {
		cmd = {
			"curl",
			"-X", "POST",
			"-H", "Content-Type: application/json",
			"-d", payload,
			integration.url
		},
	}
end

return M
