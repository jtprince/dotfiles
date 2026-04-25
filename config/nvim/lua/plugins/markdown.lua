-- Markdown: markview (in-buffer preview) + markdown-preview.nvim (browser).

require("markview").setup({
	auto_start = false,
	auto_close = false,
	dark_theme = true,
	preview = { enable = false },
})

vim.g.mkdp_auto_start = 0
vim.g.mkdp_echo_preview_url = 1
vim.g.mkdp_browser = "firefox"
