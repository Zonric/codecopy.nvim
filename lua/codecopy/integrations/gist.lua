local M = {}

---Builds the payload
function M.build(data)
	local integration = data.selected_integration
  local payload_builder = {
    description = data.message .."\n",
    public = integration.public or false,
    files = {
      [data.file.name] = {
        content = data.codecopy,
      }
    }
  }

	local payload = vim.fn.json_encode(payload_builder)

	return {
		cmd = {
			"curl",
			"-X", "POST",
			"-H", "Accept: application/vnd.github+json",
			"-H", "Authorization: Bearer " .. integration.token,
			"-H", "X-GitHub-Api-Version: 2022-11-28",
			"-d", payload,
			"https://api.github.com/gists",
		},
	}
end

return M
