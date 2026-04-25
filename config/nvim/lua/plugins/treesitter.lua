-- nvim-treesitter (main branch) — install parsers and set up.

require("nvim-treesitter").setup()

pcall(function()
	require("nvim-treesitter").install({
		"lua", "python", "vim", "vimdoc", "markdown", "markdown_inline", "yaml", "latex",
	})
end)
