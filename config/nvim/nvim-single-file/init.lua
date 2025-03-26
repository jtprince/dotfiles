---------------------------
-- Early settings
---------------------------
-- Ensure proper colors in Neovide and terminal
vim.g.neovide_hide_titlebar = true
vim.opt.termguicolors = true

-- Helper function for transparency formatting
local alpha = function()
	return string.format("%x", math.floor(255 * vim.g.transparency or 0.8))
end

if vim.g.neovide then
	vim.g.neovide_scale_factor = 1.1
	vim.g.neovide_scroll_animation_length = 0.00
	vim.g.transparency = 0.8

	-- g:neovide_opacity should be 0 if you want to unify transparency of content and title bar.
	vim.g.neovide_opacity = 0.0
	vim.g.neovide_background_color = "#0f1117" .. alpha()
	vim.g.neovide_cursor_animate_in_insert_mode = false

	-- Increase repeat rate (default is 40, lower is faster)
	vim.g.neovide_repeat_rate = 20

	-- Increase refresh rate for smoother input
	vim.g.neovide_refresh_rate = 144

	-- Disable cursor animation for instant movement
	vim.g.neovide_cursor_animation_length = 0

	-- Disable floating blur effect for instant rendering
	vim.g.neovide_floating_blur_amount_x = 0.0
	vim.g.neovide_floating_blur_amount_y = 0.0

	-- Enable fast input responses
	vim.g.neovide_input_use_logo = false
end

---------------------------
-- VS Code check
---------------------------
local is_vscode = vim.g.vscode ~= nil

---------------------------
-- Plugin manager: lazy.nvim (2024/2025 approach)
---------------------------
-- This snippet bootstraps lazy.nvim if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git", "clone", "--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath
	})
end
vim.opt.rtp:prepend(lazypath)


vim.opt.clipboard:append("unnamedplus")
if vim.g.neovide then
	-- Use Cmd+C to copy to the system clipboard
	vim.keymap.set("v", "<D-c>", '"+y', { noremap = true, silent = true }) -- Copy
	vim.keymap.set("n", "<D-c>", '"+yy', { noremap = true, silent = true }) -- Copy line

	-- Use Cmd+V to paste from the system clipboard
	vim.keymap.set({ "n", "v", "i" }, "<D-v>", '"+p', { noremap = true, silent = true }) -- Paste in normal/insert/visual mode
	vim.keymap.set("c", "<D-v>", "<C-R>+", { noremap = true, silent = true })     -- Paste in command mode

	-- Use Cmd+X to cut to the system clipboard
	vim.keymap.set("v", "<D-x>", '"+d', { noremap = true, silent = true }) -- Cut in visual mode
	vim.keymap.set("n", "<D-x>", '"+dd', { noremap = true, silent = true }) -- Cut line in normal mode
else
	-- figure out how to get copy and paste working in neovim cli alacritty
end



---------------------------
-- Plugin specifications
---------------------------
require('lazy').setup({

	-- Theme
	{
		"dracula/vim",
		name = "dracula",
		config = function()
			vim.cmd("colorscheme dracula") -- Apply the theme first

			-- ensure transparent background regardless of theme
			vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
			vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
			vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
			vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
			vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
			vim.api.nvim_set_hl(0, "VertSplit", { bg = "none" })

			-- override the cursor color after the theme loads
			vim.api.nvim_set_hl(0, "Cursor", { fg = "#000000", bg = "#FFA500" })

			-- Ensure 'guicursor' is set correctly
			vim.opt.guicursor = "n-v-c:block-Cursor,i-ci-ve:ver25-Cursor,r-cr:hor20-Cursor,o:hor50-Cursor"

			-- Neovide-specific cursor settings
			if vim.g.neovide then
				vim.g.neovide_cursor_vfx_mode = "railgun" -- Optional visual effect
				vim.g.neovide_cursor_animate_in_insert_mode = false
				vim.g.neovide_cursor_animate_command_line = false
				vim.g.neovide_cursor_trail_size = 0.8
				vim.g.neovide_cursor_color = "#FFA500" -- Explicitly set cursor color
			end
		end
	},

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = { "lua", "python", "vim", "markdown" }, -- Add languages you need
				highlight = { enable = true },
			})
		end
	},

	-- Autocompletion
	(not is_vscode) and {
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
		},
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<Tab>"]   = cmp.mapping.select_next_item(),
					["<S-Tab>"] = cmp.mapping.select_prev_item(),
					["<CR>"]    = cmp.mapping.confirm({ select = true }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				}),
			})
		end
	} or nil,

	-- Mason (for easy LSP/tool installation)
	(not is_vscode) and {
		"williamboman/mason.nvim",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			"neovim/nvim-lspconfig",
		},
		config = function()
			require("mason").setup()
			require("mason-lspconfig").setup({
				-- Python, Lua, Markdown
				ensure_installed = { "pyright", "lua_ls", "marksman" }
			})

			local lspconfig = require("lspconfig")
			require("mason-lspconfig").setup_handlers({
				function(server_name)
					lspconfig[server_name].setup({
						capabilities = require("cmp_nvim_lsp").default_capabilities(),
					})
				end,
			})

			-- Special settings for Lua LSP
			lspconfig.lua_ls.setup({
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
						workspace = { library = vim.api.nvim_get_runtime_file("", true) },
						format = { enable = true },
					}
				}
			})
		end
	} or nil,

	-- Telescope (fuzzy finder)
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		cmd = "Telescope",
		config = function()
			require("telescope").setup({
				defaults = {
					prompt_prefix = "> ",
					selection_caret = " ",
					path_display = { "smart" },
				},
			})
		end
	},

	-- Gitsigns
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("gitsigns").setup()
		end
	},
})

---------------------------
-- Additional keymaps, basic settings, etc.
---------------------------
-- Basic settings
-- vim.opt.number = true
-- vim.opt.relativenumber = true
vim.opt.hlsearch = true
vim.opt.hidden = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wrap = true
-- vim.opt.scrolloff = 8
-- vim.opt.sidescrolloff = 8

vim.g.mapleader = ","
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })

---------------------------
-- Auto-formatting on Save
---------------------------
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.lua",
	callback = function()
		vim.lsp.buf.format({ async = false })
	end
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.md",
	callback = function()
		vim.lsp.buf.format({ async = false })
	end
})


-- Add Cmd+A (⌘A) to select all (this will work on the gui)
vim.keymap.set('n', '<D-a>', 'ggVG', { noremap = true, silent = true })
vim.keymap.set('i', '<D-a>', '<Esc>ggVG', { noremap = true, silent = true })
vim.keymap.set('v', '<D-a>', '<Esc>ggVG', { noremap = true, silent = true })

-- Add this to alacritty to convert Cmd+A to Ctrl-A, then can get same behavior in terminal
-- [[keyboard.bindings]]
-- key = "G"
-- mods = "Command"
-- chars = "\u0007"  # Ctrl-G = ASCII 7

vim.keymap.set('n', '<C-g>', 'ggVG', { noremap = true, silent = true })
vim.keymap.set('i', '<C-g>', '<Esc>ggVG', { noremap = true, silent = true })
vim.keymap.set('v', '<C-g>', '<Esc>ggVG', { noremap = true, silent = true })

-- semicolon same as colon to make it easier to run various commands
vim.keymap.set('n', ';', ':', { noremap = true })
