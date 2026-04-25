-- Python-specific buffer settings. Loaded by Neovim for python filetype.

local abbrevs = {
	improt = "import",
	imrpot = "import",
	imrpt  = "import",
	imprt  = "import",
	iport  = "import",
	impot  = "import",
	impowt = "import",
	imropt = "import",
	ipt    = "import",
	ii     = "import",
	prtin  = "print",
}
for k, v in pairs(abbrevs) do
	vim.cmd(string.format("iabbrev <buffer> %s %s", k, v))
end

vim.keymap.set("n", ",B", "Obreakpoint()<Esc>0w", { buffer = true, desc = "Insert breakpoint()" })
vim.keymap.set("n", "]]", [[/^\s*\(class\|def\)\s<CR>]], { buffer = true, desc = "Next class/def" })
vim.keymap.set("n", "[[", [[?^\s*\(class\|def\)\s<CR>]], { buffer = true, desc = "Prev class/def" })

-- :InsertCommandlineProgram — read in argparse template above the cursor.
if not vim.g._python_commands_defined then
	vim.api.nvim_create_user_command("InsertCommandlineProgram", function()
		if vim.bo.filetype ~= "python" then
			vim.notify("InsertCommandlineProgram is only for Python buffers", vim.log.levels.WARN)
			return
		end
		vim.cmd("silent .-1read ~/.config/nvim/ftplugin/python-fragments/commandline_program.py")
	end, { desc = "Insert argparse command-line program template" })
	vim.g._python_commands_defined = true
end

-- Disable slow legacy omnifunc on python buffers.
vim.bo.omnifunc = ""
