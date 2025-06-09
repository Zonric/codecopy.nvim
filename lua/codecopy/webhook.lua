local M = {}
local config = require("codecopy.config")
local author = config.options.webhook.author

function M.send(webhook_url, message, codecopy)
	local fname = vim.api.nvim_buf_get_name(0)
	local file_path = ""
	if config.options.include_file_path then
		file_path = fname
	end
	local payload_builder = {
		content = message,
		embeds = {
			{
				title = file_path,
				description = codecopy,
				color = 4321431,
				author = {
					name = author.name,
					url = author.profile,
				}
			}
		}
	}
	local payload = vim.fn.json_encode(payload_builder)

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

