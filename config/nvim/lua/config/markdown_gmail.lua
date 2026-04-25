-- Convert the current markdown buffer to Gmail-ready HTML and copy it.
-- Exposed as :MarkdownCopyGmailHtml.

local function markdown_copy_gmail_html()
	local path = vim.api.nvim_buf_get_name(0)
	if path == "" then
		vim.notify("MarkdownCopyGmailHtml: save the buffer first", vim.log.levels.ERROR)
		return
	end

	if vim.bo.filetype ~= "markdown" then
		vim.notify("MarkdownCopyGmailHtml: current buffer is not markdown", vim.log.levels.ERROR)
		return
	end

	if vim.bo.modified then
		vim.cmd.write()
	end

	local converter = vim.fn.expand("~/bin/markdown/markdown-to-email")
	if vim.fn.executable(converter) ~= 1 then
		vim.notify("MarkdownCopyGmailHtml: markdown-to-email script not found", vim.log.levels.ERROR)
		return
	end

	local convert = vim.system({ converter, path }, { text = true }):wait()
	if convert.code ~= 0 then
		vim.notify(
			"MarkdownCopyGmailHtml: conversion failed\n" .. ((convert.stderr and convert.stderr ~= "") and convert.stderr or ""),
			vim.log.levels.ERROR
		)
		return
	end

	local html_path = vim.trim(convert.stdout or "")
	if html_path == "" or vim.fn.filereadable(html_path) ~= 1 then
		vim.notify("MarkdownCopyGmailHtml: could not find generated HTML output", vim.log.levels.ERROR)
		return
	end

	local html = table.concat(vim.fn.readfile(html_path), "\n")
	if html == "" then
		vim.notify("MarkdownCopyGmailHtml: generated HTML was empty", vim.log.levels.ERROR)
		return
	end

	local copy_result
	if vim.fn.has("mac") == 1 then
		copy_result = vim.system({
			"osascript",
			"-e", "on run argv",
			"-e", "set the clipboard to (read (POSIX file (item 1 of argv)) as «class HTML»)",
			"-e", "end run",
			html_path,
		}, { text = true }):wait()
	elseif vim.env.WAYLAND_DISPLAY and vim.fn.executable("wl-copy") == 1 then
		copy_result = vim.system({ "wl-copy", "--type", "text/html" }, { stdin = html, text = true }):wait()
	else
		vim.notify("MarkdownCopyGmailHtml: no supported HTML clipboard tool found", vim.log.levels.ERROR)
		return
	end

	if copy_result.code ~= 0 then
		vim.notify(
			"MarkdownCopyGmailHtml: clipboard copy failed\n" .. ((copy_result.stderr and copy_result.stderr ~= "") and copy_result.stderr or ""),
			vim.log.levels.ERROR
		)
		return
	end

	vim.notify("Copied Gmail-ready HTML to the clipboard", vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("MarkdownCopyGmailHtml", markdown_copy_gmail_html, {
	desc = "Convert current markdown buffer to Gmail-ready HTML and copy it",
})
