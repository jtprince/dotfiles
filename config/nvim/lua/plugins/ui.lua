-- Theme + UI plugins: onedark, oil, mini.icons, minimap.

vim.cmd("colorscheme onedark")

if vim.g.neovide then
	vim.g.transparency = 0.8
	local alpha = function()
		return string.format("%02x", math.floor(255 * (vim.g.transparency or 0.8)))
	end
	vim.g.neovide_background_color = "#0f1117" .. alpha()
	vim.g.neovide_opacity = 1.0
end

for _, group in ipairs({
	"Normal", "NormalNC", "NormalFloat",
	"FloatBorder", "SignColumn", "VertSplit",
}) do
	vim.api.nvim_set_hl(0, group, { bg = "none" })
end

vim.api.nvim_set_hl(0, "Cursor", { fg = "#000000", bg = "#FF00FF" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = "#44475a", bg = "none" })
vim.opt.guicursor = "n-v-c:block-Cursor,i-ci-ve:ver25-Cursor,r-cr:hor20-Cursor,o:hor50-Cursor"

if vim.g.neovide then
	vim.g.neovide_cursor_vfx_mode = "railgun"
	vim.g.neovide_cursor_animate_in_insert_mode = false
	vim.g.neovide_cursor_animate_command_line = false
	vim.g.neovide_cursor_trail_size = 0.8
	vim.g.neovide_cursor_color = "#FFA500"
end

require("mini.icons").setup()

require("oil").setup({ default_file_explorer = true })
vim.keymap.set("n", "-", "<cmd>Oil<CR>", { desc = "Open parent directory (Oil)" })

vim.keymap.set("n", "<leader>mm", "<cmd>MinimapToggle<CR>", { silent = true, desc = "Toggle minimap" })
