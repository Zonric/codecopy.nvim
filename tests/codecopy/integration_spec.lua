local config = require("codecopy.config")
local state = require("codecopy.state")

describe("integration dispatch", function()
	local original_notify
	local original_schedule_wrap
	local original_system
	local notifications
	local schedule_wrapped

	before_each(function()
		original_notify = vim.notify
		original_schedule_wrap = vim.schedule_wrap
		original_system = vim.system
		notifications = {}
		schedule_wrapped = false
		vim.notify = function(message, level)
			table.insert(notifications, { message = message, level = level })
		end
		vim.schedule_wrap = function(callback)
			schedule_wrapped = true
			return callback
		end
		config.options.env.enabled = true
		config.options.messages.silent = false
		state.data.selected_integration = { target = "test" }
		package.loaded["codecopy.integrations.test"] = nil
	end)

	after_each(function()
		vim.notify = original_notify
		vim.schedule_wrap = original_schedule_wrap
		vim.system = original_system
		package.loaded["codecopy.integrations.test"] = nil
		state.data.selected_integration = nil
	end)

	it("runs the integration command and passes the completed result", function()
		local handled
		local completed = { code = 0, signal = 0, stdout = '{"ok":true}', stderr = "" }
		package.loaded["codecopy.integrations.test"] = {
			build = function()
				return { cmd = { "example", "--flag" } }
			end,
			handle_response = function(result)
				handled = result
			end,
		}
		vim.system = function(cmd, opts, callback)
			assert.are.same({ "example", "--flag" }, cmd)
			assert.is_true(opts.text)
			callback(completed)
			return {}
		end

		require("codecopy.integration").dispatch()

		assert.are.equal(completed, handled)
		assert.are.equal(0, #notifications)
		assert.is_true(schedule_wrapped)
	end)

	it("does not start a process for clipboard integrations", function()
		local called = false
		state.data.selected_integration = { target = "clipboard" }
		vim.system = function()
			called = true
		end

		require("codecopy.integration").dispatch()

		assert.is_false(called)
	end)

	it("reports process failures without calling the response handler", function()
		local handled = false
		package.loaded["codecopy.integrations.test"] = {
			build = function()
				return { cmd = { "example" } }
			end,
			handle_response = function()
				handled = true
			end,
		}
		vim.system = function(_, _, callback)
			callback({ code = 7, signal = 0, stdout = "", stderr = "request failed\n" })
			return {}
		end

		require("codecopy.integration").dispatch()

		assert.is_false(handled)
		assert.are.equal(1, #notifications)
		assert.matches("request failed", notifications[1].message, 1, true)
	end)

	it("falls back to the exit code when a signaled process has no stderr", function()
		package.loaded["codecopy.integrations.test"] = {
			build = function()
				return { cmd = { "example" } }
			end,
			handle_response = function() end,
		}
		vim.system = function(_, _, callback)
			callback({ code = 1, signal = 15, stdout = "", stderr = "" })
			return {}
		end

		require("codecopy.integration").dispatch()

		assert.are.equal(1, #notifications)
		assert.matches("code 1", notifications[1].message, 1, true)
	end)

	it("reports failures to start the command", function()
		package.loaded["codecopy.integrations.test"] = {
			build = function()
				return { cmd = { "missing" } }
			end,
			handle_response = function() end,
		}
		vim.system = function()
			error("executable not found")
		end

		require("codecopy.integration").dispatch()

		assert.are.equal(1, #notifications)
		assert.matches("executable not found", notifications[1].message, 1, true)
	end)
end)

describe("integration responses", function()
	local original_notify
	local original_setreg
	local notifications
	local register

	before_each(function()
		original_notify = vim.notify
		original_setreg = vim.fn.setreg
		notifications = {}
		register = nil
		vim.notify = function(message, level)
			table.insert(notifications, { message = message, level = level })
		end
		vim.fn.setreg = function(_, value)
			register = value
		end
		config.options.messages.notify = true
		config.options.messages.debug = false
		config.options.codecopy.gist_to_clipboard = false
	end)

	after_each(function()
		vim.notify = original_notify
		vim.fn.setreg = original_setreg
	end)

	it("handles Gist JSON responses", function()
		local gist = require("codecopy.integrations.gist")
		config.options.codecopy.gist_to_clipboard = true

		gist.handle_response({ stdout = '{"html_url":"https://gist.github.com/example"}' })

		assert.are.equal("https://gist.github.com/example", register)
		assert.matches("copied to clipboard", notifications[1].message, 1, true)
	end)

	it("handles Discord success and error responses", function()
		local discord = require("codecopy.integrations.discord")

		discord.handle_response({ stdout = "" })
		discord.handle_response({ stdout = '{"message":"Invalid Webhook Token"}' })

		assert.are.equal(2, #notifications)
		assert.matches("successfully", notifications[1].message, 1, true)
		assert.matches("Invalid Webhook Token", notifications[2].message, 1, true)
	end)

	it("accepts Discord wait responses as successful", function()
		local discord = require("codecopy.integrations.discord")

		discord.handle_response({ stdout = '{"id":"123","content":"sent"}' })

		assert.are.equal(1, #notifications)
		assert.matches("successfully", notifications[1].message, 1, true)
	end)

	it("uses Slack's top-level response fields", function()
		local slack = require("codecopy.integrations.slackcompat")

		slack.handle_response({ stdout = '{"ok":true}' })
		slack.handle_response({ stdout = '{"ok":false,"error":"channel_not_found"}' })

		assert.are.equal(2, #notifications)
		assert.matches("successfully", notifications[1].message, 1, true)
		assert.matches("channel_not_found", notifications[2].message, 1, true)
	end)

	it("uses Zulip's result and message fields", function()
		local zulip = require("codecopy.integrations.zulip")

		zulip.handle_response({ stdout = '{"result":"success","msg":""}' })
		zulip.handle_response({ stdout = '{"result":"error","msg":"Unknown channel"}' })

		assert.are.equal(2, #notifications)
		assert.matches("successfully", notifications[1].message, 1, true)
		assert.matches("Unknown channel", notifications[2].message, 1, true)
	end)

	it("reports malformed service responses", function()
		require("codecopy.integrations.gist").handle_response({ stdout = "not json" })
		require("codecopy.integrations.discord").handle_response({ stdout = "not json" })
		require("codecopy.integrations.slackcompat").handle_response({ stdout = "not json" })
		require("codecopy.integrations.zulip").handle_response({ stdout = "not json" })

		assert.are.equal(4, #notifications)
		for _, notification in ipairs(notifications) do
			assert.are.equal(vim.log.levels.ERROR, notification.level)
		end
	end)
end)
