local options = require("codecopy.config").options

vim.api.nvim_create_user_command("CodeCopy", function(opts)
	local args = vim.split(opts.args, "%s+")
	local cmd = table.concat(args, " ")

	if cmd == "toggle debug" then
		require("codecopy.config").toggle_debug()
	elseif cmd == "toggle notify" then
		require("codecopy.config").toggle_notify()
	elseif cmd == "toggle code_fence" then
		require("codecopy.config").toggle_code_fence()
	elseif cmd == "toggle include_file_path" then
		require("codecopy.config").toggle_include_file_path()
	elseif cmd == "toggle openui" then
		require("codecopy.config").toggle_openui()
	elseif cmd == "toggle gist_to_clipboard" then
		require("codecopy.config").toggle_gist_to_clipboard()
	elseif cmd == "open ui" then
		require("codecopy.ui").open()
	elseif cmd == "" then
		require("codecopy.selection").copy()
	else
		if not options.messages.silent then
			vim.notify("Unknown CodeCopy subcommand: " .. cmd, vim.log.levels.WARN, { title = "CodeCopy Commands:" })
		end
	end
end, {
	nargs = "*",
	complete = function(_, line)
		local subcommands = {
			"open ui",
			"toggle debug",
			"toggle notify",
			"toggle code_fence",
			"toggle include_file_path",
			"toggle openui",
			"toggle gist_to_clipboard",
		}
		return vim.tbl_filter(function(cmd)
			return cmd:find("^" .. vim.trim(line:sub(#":CodeCopy" + 1)))
		end, subcommands)
	end,
	desc = "CodeCopy main command with subcommands.",
})
