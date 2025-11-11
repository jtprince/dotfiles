-- The following were derived from a debug session with chatgpt
-- Basically, if I don't do something like this, then it takes 3 seconds
-- for the old vim python omnifunc to load *for every python file I open*
vim.g.did_load_filetypes = nil
vim.g.do_filetype_lua = 1            -- use the fast Lua system

vim.g.did_ftplugin = 1
vim.g.did_indent_on = 1
vim.g.skip_loading_python_provider = true

-- Prevent built-in omnifunc from initializing
vim.g.loaded_python3_provider = 1

-- Optional: disable Python syntax files too
-- vim.g.skip_loading_syntax = true
