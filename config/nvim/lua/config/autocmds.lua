-- Global autocmds (filetype-specific autocmds live in ftplugin/<ft>.lua).

local aug = vim.api.nvim_create_augroup("user_autocmds", { clear = true })

-- py2nb cell-marker comments.
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	group = aug,
	pattern = "*.py",
	callback = function()
		vim.cmd([[
			syntax match Comment "#|.*$"
			syntax match Special "#!.*$"
			syntax match Delimiter "#-.*$"
		]])
	end,
})

-- Auto-format Lua on save (LSP).
vim.api.nvim_create_autocmd("BufWritePre", {
	group = aug,
	pattern = "*.lua",
	callback = function()
		vim.lsp.buf.format({ async = false })
	end,
})
