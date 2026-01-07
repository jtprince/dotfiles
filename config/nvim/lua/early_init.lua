-- early_init.lua
-- Goal: keep filetype/ftplugin/indent fast, but avoid slow legacy Python omnifunc loads

-- Modern, fast filetype detection
vim.g.did_load_filetypes = nil
vim.g.do_filetype_lua = 1

-- DO NOT disable ftplugins/indent globally; this breaks lots of useful defaults.
-- vim.g.did_ftplugin = 1
-- vim.g.did_indent_on = 1

-- Disable Python provider ONLY if you truly don't need python-hosted plugins.
-- (Many people do fine without it; keep it if you want fastest startup.)
vim.g.loaded_python3_provider = 0
-- If you *really* want python provider fully disabled:
-- vim.g.loaded_python3_provider = 1

-- ----
-- Fix the slow python omnifunc loading:
-- Disable the legacy omnifunc *only for python buffers*.
-- ----
vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		-- Prevent legacy omnifunc (sometimes triggers slow runtime loads)
		vim.bo.omnifunc = ""
	end,
})
