---------------------------------------------------------------------------
-- init.lua — Neovim 0.12+ entry point.
-- Author: J.T. Prince
--
-- Layout:
--   lua/config/*.lua  — editor settings (no plugins required)
--   lua/plugins/*.lua — plugin specs and per-plugin setup (loaded via vim.pack)
--   ftplugin/<ft>.lua — filetype-specific buffer config
---------------------------------------------------------------------------

-- Speed up Lua module loading.
pcall(function() vim.loader.enable() end)

-- We don't use python-hosted plugins; skip the provider for faster startup.
vim.g.loaded_python3_provider = 0

vim.g.mapleader = ","
vim.g.maplocalleader = ","

require("config.options")
require("config.neovide")
require("config.clipboard")
require("config.keymaps")
require("config.autocmds")
require("config.markdown_gmail")

-- Plugins (skipped under VS Code, where Neovim is embedded).
if not vim.g.vscode then
	require("plugins")
end
