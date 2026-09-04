local M = {}
---Prepares a module name for integrations based on selection in `state.ui.sections.integration.win`
---and stored in `state.data.selected_integration`.target as defined in users env.json
---Gets the cmd from the integration module and executes it.
function M.dispatch()
	local options = require("codecopy.config").options
	local state = require("codecopy.state")
	local integration = state.data.selected_integration

	if integration == nil or integration.target == "clipboard" then
		-- nothing to do here, Im outta here...
		return
	end

	local module_name = ""
	if options.env.enabled then
		module_name = "codecopy.integrations." .. integration.target
	else
		if not options.messages.silent then
			vim.notify("Integration not found: " .. integration.target, vim.log.levels.ERROR, { title = "CodeCopy integration Error:" })
		end
		-- check in user dir for integration. if still not found give erro
		return
	end

	local ok, integration_module = pcall(require, module_name)
	if not ok then
		if not options.messages.silent then
			vim.notify("Missing integration: " .. module_name, vim.log.levels.ERROR, { title = "CodeCopy integration Error:" })
		end
		if not options.messages.silent and options.messages.debug then
			vim.notify("integration_module:\n" .. vim.inspect(integration_module), vim.log.levels.DEBUG, { title = "CodeCopy integration Debug:" })
		end
		return
	end

	local results = integration_module.build(state.data)

	local on_exit = vim.schedule_wrap(function(result)
		if result.code ~= 0 or result.signal ~= 0 then
			if not options.messages.silent then
				local detail = vim.trim(result.stderr or "")
				if detail == "" then
					detail = "Process exited with code " .. result.code
				end
				vim.notify("Integration command failed:\n    " .. detail, vim.log.levels.ERROR, { title = "CodeCopy Integration Error:" })
			end
			return
		end

		if not options.messages.silent then
			integration_module.handle_response(result)
		end
	end)

	local ok, err = pcall(vim.system, results.cmd, { text = true }, on_exit)
	if not ok and not options.messages.silent then
		vim.notify("Failed to start integration command:\n    " .. tostring(err), vim.log.levels.ERROR, { title = "CodeCopy Integration Error:" })
	end
end

return M
