-- env var expected SLACKCOMPAT_WEBHOOK
local M = {}

M.get_payload = function(message, codecopy)
	local payload = {
		blocks = {
			{
				type = "section",
				text = {
					type = "mrkdwn",
					text = message,
				},
			},
			{
				type = "section",
				text = {
					type = "mrkdwn",
					text = codecopy,
				},
			},
		},
	}
	return vim.fn.json_encode(payload)
end

return M
