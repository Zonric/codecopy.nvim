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
		vim.notify("Integration not found: " .. integration.target, vim.log.levels.ERROR, { title = "CodeCopy Error:" })
		-- check in user dir for integration. if still not found give erro
		return
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
		stdout_buffered = true,
		on_stdout = function(_, data)
			if options.debug or options.notify then
				integration_module.handle_response(data)
			end
		end,
		on_exit = function(_, code)
			if code ~= 0 then
				vim.notify("Integration's `command` extited with code: " .. code, vim.log.levels.ERROR, { title = "CodeCopy Integration Error:" })
			end
		end,
	})
end

return M
