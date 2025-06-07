local M = {}
local config = require("codecopy.config")
local options = config.options

function M.setup(opts)
	config.setup(opts)
	local key = options.keymap
	vim.keymap.set("v", key, "<CMD>CodeCopy<CR>", { desc = "CodeCopy: copy selection.", silent = true })
end
return M

