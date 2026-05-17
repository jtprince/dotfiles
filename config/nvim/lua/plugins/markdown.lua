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

-- Zola Preview command
vim.api.nvim_create_user_command('MarkdownZolaPreview', function()
  -- Save the file (Zola serve will detect the change and rebuild)
  vim.cmd('write')
  
  -- Get the current file path
  local file_path = vim.fn.expand('%:p')
  
  -- Call the resolution script from the project root
  -- It auto-starts 'zola serve' if it's not already running.
  local script_path = vim.fn.getcwd() .. "/scripts/resolve_zola_url.py"
  if vim.fn.filereadable(script_path) == 1 then
    local open_cmd = "python3 " .. script_path .. " " .. vim.fn.shellescape(file_path) .. " --open"
    -- Run the command in the background
    vim.fn.jobstart(open_cmd, { detach = true })
  else
    print("Error: scripts/resolve_zola_url.py not found in current directory.")
  end
end, { desc = 'Preview Zola Markdown in browser via zola serve (auto-starts if needed)' })
