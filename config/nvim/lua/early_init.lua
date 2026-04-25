-- early_init.lua
-- Loaded via init.lua at startup. Keeps things minimal.

-- Disable Python provider (we don't use python-hosted plugins; this speeds startup)
vim.g.loaded_python3_provider = 0

-- Avoid the slow legacy Python omnifunc on python buffers
vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		vim.bo.omnifunc = ""
	end,
})

