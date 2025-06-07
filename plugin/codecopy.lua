if vim.g.loaded_codecopy then
	return
end
vim.g.loaded_codecopy = true

vim.api.nvim_create_user_command("CodeCopy", function()
	require("codecopy.visualselection").copy()
end, { desc = "Copy code block under cursor to clipboard in markdown format." })
