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
    opts = { -- Default Configs
    -- sets Default keymap for ("codecopy.visualselection").copy() using built in user command `CodeCopy`
        keymap = "<leader>cc",
        code_fence = true,
        notify = false,
        include_file_path = false,
        debug = false,
        lang_map = {
            ["py"] = "python", -- see included lang_map for default
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

\`\`\`lua
...
   your visual selection
...
\`\`\`

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

🧪 Example Keymap
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
