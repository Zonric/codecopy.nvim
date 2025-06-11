local internal = require("codecopy.internal")
describe("it should parse the env vars", function()
	local expected_key = "DISCORD_WEBHOOK"
	local expected_value = "https://discord.com/api/webhooks/123456789012345678/abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

	it("should parse a simple env file", function()
		local filepath = vim.uv.cwd() .. "/tests/codecopy/test.env"
		local result = internal.parse_env(filepath)
		assert(result[expected_key])
		assert.are.equal(expected_value, result[expected_key])
	end)
end)
