-- env var expected DISCORD_WEBHOOK
local M = {}

M.get_payload = function(message, codecopy)
	local payload = {
		content = message,
		embeds = {
			{
				title = "codecopy.nvim",
				description = codecopy,
				color = 4321431,
			},
		},
	}
	return vim.fn.json_encode(payload)
end

return M
