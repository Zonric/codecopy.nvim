local M = {}

---Prepares a module name for integrations based on selection in `state.ui.sections.integration.win`
---and stored in `state.data.selected_integration`.target as defined in users env.json
---Gets the cmd from the integration module and executes it.
function M.dispatch()
	local options = require("codecopy.config").options
	local state = require("codecopy.state")
	local integration = state.data.selected_integration
	if integration.target == "clipboard" then
		return
	end
	local module_name = ""
	if options.env.enabled then
		module_name = "codecopy.integrations." .. integration.target
	else
		module_name = "codecopy.integrations.default"
	end
	local ok, integration_module = pcall(require, module_name)
	if not ok then
		vim.notify("Missing integration: " .. module_name, vim.log.levels.ERROR, { title = "CodeCopy Error:" })
		if options.debug then
			vim.notify(vim.inspect(integration_module))
		end
		return
	end

	local results = integration_module.build(state.data)

	---Executes the cmd in a new job.
	vim.fn.jobstart(results.cmd, {
		on_exit = function(_, code)
			if code ~= 0 then
				vim.notify("curl exited with code: " .. code, vim.log.levels.ERROR, { title = "CodeCopy Error:" })
			end
		end,
		on_stdout = function(_, data)
			local d = vim.fn.json_decode(data[1])
			if d.result == "success" then
				vim.notify("Payload sent successfully.", vim.log.levels.INFO, { title = "CodeCopy Info:" })
			else
				vim.notify("Payload failed", vim.log.levels.ERROR, { title = "CodeCopy Error:" })
			end
		end,
		stdout_buffered = true,
	})
end

return M
