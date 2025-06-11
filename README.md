# 📋 codecopy.nvim

A simple Neovim plugin to copy visually selected text to the system clipboard — optionally wrapped in code fences (for Discord, GitHub, etc). Designed to be lightweight and configurable.

---

## ✨ Features

- 📦 Copy visual selection to clipboard
- 💻 Wrap in code fences (e.g., \`\`\`lua )
- 🗺️ Optional header displaying file path (e.g., `### /some/file.ext` )
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
        include_file_path = false, -- will use your `p` register 
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
            intergation = "discord",
            -- Optional : UNRECCOMMENDED way to pass webhook url
            -- will be overridden if env is setup.
            url = "",
        },
        -- Optional: lang_map override
        lang_map = {
            ["py"] = "python", -- :see below: For default lang_map
        },
    },
}
```
Included lang_map:
```text
["ahk"] = "ahk", ["bash"] = "bash", ["bat"] = "bat",
["c"] = "c", ["c++"] = "cpp", ["cc"] = "cpp",
["cmd"] = "bat", ["cpp"] = "cpp", ["css"] = "css",
["cxx"] = "cpp", ["diff"] = "diff", ["go"] = "go",
["h++"] = "cpp", ["hh"] = "cpp", ["hpp"] = "cpp",
["htm"] = "html", ["html"] = "html", ["xhtml"] = "html",
["hxx"] = "cpp", ["ini"] = "ini", ["java"] = "java",
["js"] = "javascript", ["lua"] = "lua", ["md"] = "markdown",
["patch"] = "diff", ["py"] = "python", ["rust"] = "rust",
["sh"] = "bash", ["ts"] = "typescript", ["zsh"] = "zsh",
["php"] = "php", ["blade"] = "html", ["text"] = "txt",
["vim"] = "vim", ["xml"] = "xml", ["xsl"] = "xml",
["yaml"] = "yaml", ["yml"] = "yaml",
```

---

🗝️ Usage

In visual mode, select some text and press `<leader>cc` (or your custom mapping).

The text will be copied to the system clipboard, wrapped in:

```
\```lua
...
   local your_visual_selection = "Placed inside code block"
...

\```
```

If you want to copy plain text, you can toggle ("codecopy.config").toggle_code_fence() on the fly.

---

🔧 API

| Function                                                | Description                  | Modes   |
|---------------------------------------------------------|------------------------------|---------|
| `require("codecopy.visualselection").copy()`            | Manually trigger copy.       | "v"     |
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
