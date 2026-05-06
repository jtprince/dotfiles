-- Persistence: session save/load. Setup must run synchronously at startup
-- because config/autocmds.lua's VimEnter handler calls persistence.load().
-- (Keymaps stay here too — they're cheap.)

require("persistence").setup({
	dir = vim.fn.stdpath("state") .. "/sessions/",
	need = 1,
	branch = true,
})

vim.keymap.set("n", "<leader>qs", function() require("persistence").load() end,
	{ desc = "Session load (cwd)" })
vim.keymap.set("n", "<leader>qS", function() require("persistence").select() end,
	{ desc = "Session select" })
vim.keymap.set("n", "<leader>ql", function() require("persistence").load({ last = true }) end,
	{ desc = "Session load (last)" })
vim.keymap.set("n", "<leader>qd", function() require("persistence").stop() end,
	{ desc = "Session stop saving" })
