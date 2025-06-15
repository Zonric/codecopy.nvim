local M = {}
local options = require("codecopy.config").options

function M.build(data)
	local integration = data.selected_integration
	local payload = {
		content = "",
	}
	if data.message ~= nil and data.message ~= "" then
		payload.content = "# " .. data.message .. "\n\n"
	end
	if options.codecopy.code_fence then
		payload.content = payload.content .. "```" .. data.file.lang .. "\n" .. data.codecopy .. "\n```"
	else
		payload.content = data.codecopy
	end
	if (integration.filepath == nil and options.codecopy.include_file_path) or integration.filepath then
		payload.content = payload.content .. "\n\n*" .. data.file.path .. "*"
	end

	return {
		cmd = {
			"curl",
			"-X",
			"POST",
			integration.url,
			"-u",
			integration.username .. ":" .. integration.token,
			"--data-urlencode",
			"type=stream",
			"--data-urlencode",
			"to=" .. integration.channel,
			"--data-urlencode",
			"topic=" .. integration.topic,
			"--data-urlencode",
			"content=" .. payload.content,
		},
	}
end

function M.handle_response(response)
	local response_decode = vim.fn.json_decode(response[1])
	if response_decode.result == "success" then
		if options.messages.notify or options.messages.debug then
			vim.notify("Payload sent successfully.", vim.log.levels.INFO, { title = "CodeCopy Info:" })
		end
	else
		vim.notify("Payload failed with message: \n    " .. response_decode.msg, vim.log.levels.ERROR, { title = "CodeCopy Integration Error:" })
	end
end

return M
