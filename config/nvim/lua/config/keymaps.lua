-- Global keymaps. Plugin-specific keymaps live in their plugin module.

local map = vim.keymap.set
local silent = { silent = true }

-- Semicolon behaves like colon (saves a shift).
map("n", ";", ":", { noremap = true, desc = "Command-line (colon)" })

-- Select all (Cmd+A in Neovide / Ctrl+G as terminal-friendly alt).
map("n", "<D-a>", "ggVG",      vim.tbl_extend("force", silent, { desc = "Select all" }))
map("i", "<D-a>", "<Esc>ggVG", vim.tbl_extend("force", silent, { desc = "Select all" }))
map("v", "<D-a>", "<Esc>ggVG", vim.tbl_extend("force", silent, { desc = "Select all" }))
map("n", "<C-g>", "ggVG",      vim.tbl_extend("force", silent, { desc = "Select all" }))
map("i", "<C-g>", "<Esc>ggVG", vim.tbl_extend("force", silent, { desc = "Select all" }))
map("v", "<C-g>", "<Esc>ggVG", vim.tbl_extend("force", silent, { desc = "Select all" }))

-- Window navigation.
for _, k in ipairs({ "h", "j", "k", "l" }) do
	map("n", "<C-" .. k .. ">", "<C-w>" .. k, vim.tbl_extend("force", silent, { desc = "Window " .. k }))
	map("i", "<C-" .. k .. ">", "<Esc><C-w>" .. k,
		vim.tbl_extend("force", silent, { desc = "Window " .. k .. " (insert)" }))
end

-- Terminal: <Esc> drops to normal mode for browsing output.
map("t", "<Esc>", [[<C-\><C-n>]], vim.tbl_extend("force", silent, { desc = "Terminal: normal mode" }))
