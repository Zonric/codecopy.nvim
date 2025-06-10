local M = {}
local config = require("codecopy.config")
local author = config.options.webhook.author

function M.send(webhook_url, message, codecopy, payload)
	if config.options.debug then
		print(vim.inspect(payload))
	end

	-- 	"curl", "-X", "POST", "-H", "Content-Type: application/json", "-d", payload, webhook_url
	local result = vim.fn.system({ "curl", "-X", "POST", "-H", "Content-Type: application/json", "-d", payload, webhook_url })
	if config.options.debug then
		print("Discord webhook result: ", result)
	end
end

return M
