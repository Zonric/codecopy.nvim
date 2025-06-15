-- env var expected SLACKCOMPAT_WEBHOOK
local M = {}
local options = require("codecopy.config").options

M.build = function(data)
	local integration = data.selected_integration
	local message = ""
	if data.message ~= nil and data.message ~= "" then
		message = "# " .. data.message .. "\n\n"
	end
	local codecopy = ""
	if options.codecopy.code_fence then
		codecopy = "```" .. data.file.lang .. "\n" .. data.codecopy .. "\n```"
	else
		codecopy = data.codecopy
	end
	local payload_builder = {
		channel = integration.channel,
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
	if (integration.filepath == nil and options.codecopy.include_file_path) or integration.filepath then
		table.insert(payload_builder.blocks, {
			type = "section",
			text = {
				type = "mrkdwn",
				text = "*" .. data.file.path .. "*",
			},
		})
	end

	local payload = vim.fn.json_encode(payload_builder)

	return {
		cmd = {
			"curl",
			"-X",
			"POST",
			"-H",
			"Content-Type: application/json",
			"-H",
			"Authorization: Bearer " .. integration.token,
			"-d",
			payload,
			integration.url,
		},
	}
end

function M.handle_response(response)
	---@diagnostic disable-next-line: redefined-local
	local response = vim.fn.json_decode(response[1])
	if response.result.ok then
		if options.messages.notify or options.messages.debug then
			vim.notify("Payload sent successfully.", vim.log.levels.INFO, { title = "CodeCopy Info:" })
		end
	else
		vim.notify("Payload failed:\n    " .. response.msg, vim.log.levels.ERROR, { title = "CodeCopy Error:" })
	end
end

return M
