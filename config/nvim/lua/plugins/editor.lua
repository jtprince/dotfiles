-- Editing-focused plugins: Comment, vim-table-mode, gitsigns, persistence,
-- rainbow_csv, trouble, toggleterm.

require("Comment").setup()

vim.g.table_mode_corner = "|"

require("gitsigns").setup()

require("rainbow_csv").setup()

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

require("trouble").setup()
for _, m in ipairs({
	{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",                        "Diagnostics (Trouble)" },
	{ "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",           "Buffer Diagnostics (Trouble)" },
	{ "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>",                "Symbols (Trouble)" },
	{ "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", "LSP List (Trouble)" },
	{ "<leader>xL", "<cmd>Trouble loclist toggle<cr>",                            "Location List (Trouble)" },
	{ "<leader>xQ", "<cmd>Trouble qflist toggle<cr>",                             "Quickfix List (Trouble)" },
}) do
	vim.keymap.set("n", m[1], m[2], { silent = true, desc = m[3] })
end

require("toggleterm").setup({
	size = 120,
	open_mapping = [[<C-\>]],
	direction = "vertical",
	shade_terminals = true,
	start_in_insert = true,
	insert_mappings = true,
	terminal_mappings = true,
	persist_size = true,
	persist_mode = true,
	close_on_exit = true,
})

for _, m in ipairs({
	{ "<C-h>", [[<C-\><C-n><C-w>h]], "Terminal: focus left" },
	{ "<C-j>", [[<C-\><C-n><C-w>j]], "Terminal: focus down" },
	{ "<C-k>", [[<C-\><C-n><C-w>k]], "Terminal: focus up" },
	{ "<C-l>", [[<C-\><C-n><C-w>l]], "Terminal: focus right" },
}) do
	vim.keymap.set("t", m[1], m[2], { noremap = true, silent = true, desc = m[3] })
end

vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "term://*",
	callback = function()
		if vim.bo.buftype == "terminal" then
			vim.cmd("startinsert")
		end
	end,
})
