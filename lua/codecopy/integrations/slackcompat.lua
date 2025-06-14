-- env var expected SLACKCOMPAT_WEBHOOK
local M = {}

M.get_payload = function(data)
	local options = require ("codecopy.config").options
	local integration = data.selected_integration
	local message = ""
	if data.message ~= nil and data.message ~= "" then
		message = "# "..data.message.."\n\n"
	end
	local codecopy = ""
	if options.code_fence then
		codecopy = "```"..data.file.lang.."\n"..data.codecopy.."\n```"
	else
		codecopy = data.codecopy
	end
	if options.include_file_path then
		codecopy = codecopy .. "\n\n*"..data.file.path.."*"
	end
	local payload = vim.fn.json_encode({
		blocks = {
			{
				type = "section",
				text = {
					type = "mrkdwn",
					text = message,
				},
			},{
				type = "section",
				text = {
					type = "mrkdwn",
					text = codecopy,
				},
			},
		},
	})

	return {
		cmd = {
			"curl",
			"-X", "POST",
			"-H", "Content-Type: application/json",
			"-d", payload,
			integration.url
		}
	}

end

return M
