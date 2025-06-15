local M = {}

--#region Types

---@class SelectionPos
---@field start_row integer|nil
---@field start_col integer|nil
---@field end_row integer|nil
---@field end_col integer|nil

---@class Selection
---@field mode string|nil
---@field pos SelectionPos

---@class FileMeta
---@field path string|nil     -- Absolute path to the source file
---@field name string|nil
---@field ext string|nil      -- File extension (e.g., "py", "lua")
---@field lang string|nil     -- Language identifier (e.g., "python", "lua")

---@class UISections
---@field integrations_win NuiMenu|nil   -- UI menu for selecting integrations
---@field filepath_win NuiPopup|nil      -- UI popup showing/editing file path
---@field code_win NuiPopup|nil          -- UI popup containing the editable code snippet
---@field message_win NuiPopup|nil       -- UI popup for the optional message

---@class UIModel
---@field layout NuiLayout|nil           -- Main layout container
---@field sections UISections            -- Named UI sections of the layout

---@class CodeCopyState
---@field file FileMeta                  -- Metadata about the file
---@field clipboard string|nil           -- The copied code (pre-edit)
---@field codecopy string|nil            -- The modified code (post-edit) includes: User optionals
---@field message string                 -- Optional message to attach
---@field selection Selection            -- Visual selection info
---@field selected_integration any|nil -- Selected integration (structure depends on implementation WIP)

--#endregion

---@type CodeCopyState
M.data = {
	file = {
		path = nil,
		name = nil,
		ext = nil,
		lang = nil,
	},
	clipboard = nil,
	codecopy = nil,
	message = "",
	selected_integration = nil,
	selection = {
		mode = nil,
		pos = {
			start_row = nil,
			start_col = nil,
			end_row = nil,
			end_col = nil,
		},
	},
}

---@type UIModel
M.ui = {
	layout = nil,
	sections = {
		integrations_win = nil,
		filepath_win = nil,
		code_win = nil,
		message_win = nil,
	},
}

function M.clear_data()
	M.data = {
		file = {
			path = nil,
			name = nil,
			ext = nil,
			lang = nil,
		},
		clipboard = nil,
		message = "",
		selected_integration = nil,
		selection = {
			mode = nil,
			pos = {
				start_row = nil,
				start_col = nil,
				end_row = nil,
				end_col = nil,
			},
			integration = nil,
		},
	}
end

function M.clear_ui()
	M.ui = {
		layout = nil,
		sections = {
			integrations_win = nil,
			filepath_win = nil,
			code_win = nil,
			message_win = nil,
		},
	}
end

return M
