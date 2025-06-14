# 📋 codecopy.nvim

A simple Neovim plugin to copy selected text to the system clipboard.<br>
Wrapped in markdown code fences (for Discord, GitHub, etc).
- can optout in config
[See Installation](#🔌-installation)

Designed to be lightweight and configurable.

---

![Screenshot](./.screenshot.png)

---

## ✨ Features

- 📦 Copy visual selection to clipboard
- 💻 Wrap in code fences (e.g., \`\`\`lua )
- 🗺️ Optional footer displaying file path ( */loc/of/some/file.txt* )
- 🔔 Optional notifications
- 🔧 User-configurable options and keymaps
- ⚙️ Expandable dynamic language detection
- 🧠 Minimal, fast, and fully Lua-based

---

## 🔌 Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "Zonric/codecopy.nvim",
    event = "VeryLazy",
    dependancy = { "MunifTanjim/nui.nvim" },
}
```

Default configuration:

```lua
{
    "Zonric/codecopy.nvim",
    branch = "master",
    enabled = true,
    lazy = true,
    event = "VeryLazy",
    dependancy = { "MunifTanjim/nui.nvim" },
    opts = { -- Default Configs
    -- sets Default keymap for ("codecopy.visualselection").copy()
       -- using built in user command `CodeCopy`
        keymap = "<leader>cc",
        code_fence = true,
        include_file_path = false,
        messages = {
            notify = false,
            debug = false,
        },
        env = {
            enabled = false,
            -- Prefered method to store your webhook url
            -- to avoid leaking if you repo your dotfiles
            env_path = "$HOME/.config/codecopy/env",
        },
        webhook = {
            -- Optional : UNRECCOMMENDED way to pass webhook url
            -- will be overridden if env is setup.
            branding = false, --Toggle true, to show us some love with a nod. 😉
            embed = false,
            ---Optional : Add your profile or website to the embed, if used.
            ---author = {
                ---name = "CodeCopy.nvim",
                ---profile = "https://github.com/Zonric/codecopy.nvim",
            ---},
            url = "",
        },
    },
}
```

---

🗝️ Usage

In visual mode, select some text and press `<leader>cc` (or your custom mapping).
The text will be copied to the system clipboard, wrapped in:

```text
\```lua
  ...
  local your_visual_selection = "Placed inside code block"
  ...

\```

```

If you want to copy plain text, you can toggle `require ("codecopy.config").toggle_code_fence()` on the fly.

---

🔧 API

| Function                                                | Description                  | Modes   |
|---------------------------------------------------------|------------------------------|---------|
| `require("codecopy.selection").copy()`                  | Manually trigger copy.       | "v"     |
| `require("codecopy.config").toggle_code_fence()`        | Toggle code block wrapping.  | "n","v" |
| `require("codecopy.config").toggle_notify()`            | Toggle copy notifications.   | "n","v" |
| `require("codecopy.config").toggle_include_file_path()` | Toggle displaying file path. | "n","v" |
| `require("codecopy.config").toggle_debug()`             | Toggle debut notifications.  | "n","v" |

🧪 Example Keymaps

You can set your own keymap:

```lua
vim.keymap.set("v", "<leader>cc", "<CMD>CodeCopy<CR>", { desc = "CodeCopy to clipboard" })

vim.keymap.set("n", "<leader>cn", function()
  require("codecopy.config").toggle_notify()
end, { desc = "CodeCopy toggle notifications." })

vim.keymap.set({"n","v"}, "<leader>cg", function()
  require("codecopy.config").toggle_code_fence()
end, { desc = "CodeCopy toggle fencing." })
```
