local M = {}

function M.build(data)
	local options = require ("codecopy.config").options
	local integration = data.selected_integration
	local payload = {
		content = "",
	}
	if data.message ~= nil and data.message ~= "" then
		payload.content = "# "..data.message.."\n\n"
	end
	if options.code_fence then
		payload.content = payload.content.."```"..data.file.lang.."\n"..data.codecopy.."\n```"
	else
		payload.content = data.codecopy
	end
	if options.include_file_path then
		payload.content = payload.content.."\n\n*"..data.file.path.."*"
	end

	return {
		cmd = {
			"curl",
			"-X", "POST",
			integration.url,
			"-u", integration.username..":"..integration.token,
			"--data-urlencode", "type=stream",
			"--data-urlencode", "to="..integration.channel,
			"--data-urlencode", "topic="..integration.topic,
			"--data-urlencode", "content="..payload.content,
		},
	}
end

return M
