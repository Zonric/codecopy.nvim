local M = {}
local options = require("codecopy.config").options

function M.send(payload, webhook)
	if options.messages.debug then
		print(vim.inspect(payload))
	end
	-- 	"curl -X POST -H Content-Type: application/json -d " .. payload .. " " .. webhook_url
	local result = vim.fn.system({ "curl", "-X", "POST", "-H", "Content-Type: application/json", "-d", payload, webhook })
	if options.messages.debug then
		print("Result: ", result)
	end
end

-- TODO: Need to figure out integration switching.
function M.prep(message, codecopy)
	local wh_url = ""
	if options.env.enabled then
		wh_url = require("codecopy.config").get_env().WEBHOOK_URL
	else
		wh_url = options.webhook.url
	end
	if options.messages.debug then
		vim.print(wh_url)
	end
	if wh_url ~= "" or nil then
		local payload = require("codecopy.integrations.slackcompat").get_payload(message, codecopy)
		M.send(payload, wh_url)
	else
		vim.notify("Please setup your env or define opts.webhook.url. See our README for help.",
				vim.log.levels.ERROR, { title = "CodeCopy Config Error:" })
	end
end

return M
