---------------------------
-- Early settings
---------------------------

require("early_init")

vim.g.mapleader = ","

-- Ensure proper colors in Neovide and terminal
vim.g.neovide_hide_titlebar = true
vim.opt.termguicolors = true

if vim.g.neovide then
	vim.g.neovide_scale_factor = 1.1
	vim.g.neovide_scroll_animation_length = 0.00

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

-- Auto-reload neovim config on save or :ReloadConfig
-- if not is_vscode then
-- local function reload_config()
-- 	local config_dir = vim.fn.stdpath("config")
-- 	local init_file = config_dir .. "/init.lua"
--
-- 	-- Always re-run init.lua
-- 	dofile(init_file)
--
-- 	-- Check for modular setup by looking for 'lua/' folder
-- 	local lua_dir = config_dir .. "/lua"
-- 	local stat = vim.loop.fs_stat(lua_dir)
--
-- 	if stat and stat.type == "directory" then
-- 		for name, _ in pairs(package.loaded) do
-- 			-- clear only your own modules (safeguard to avoid nuking plugins)
-- 			if name:match("^.+") and not name:match("^vim") then
-- 				package.loaded[name] = nil
-- 			end
-- 		end
-- 	end
--
-- 	vim.notify("Neovim config reloaded!", vim.log.levels.INFO)
-- end
--
-- vim.api.nvim_create_user_command("ReloadConfig", reload_config, {})
--
-- vim.api.nvim_create_autocmd("BufWritePost", {
-- 	-- when you modularize, need to change to something like this:
-- 	-- pattern = lua/**/*.lua
-- 	pattern = "init.lua",
-- 	callback = function()
-- 		reload_config()
-- 	end,
-- })
-- end

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
local function unless_vscode(spec)
	return not is_vscode and spec or nil
end

require('lazy').setup({

	unless_vscode(
		{
			"folke/trouble.nvim",
			opts = {},
			cmd = "Trouble",
			keys = {
				{
					"<leader>xx",
					"<cmd>Trouble diagnostics toggle<cr>",
					desc = "Diagnostics (Trouble)",
				},
				{
					"<leader>xX",
					"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
					desc = "Buffer Diagnostics (Trouble)",
				},
				{
					"<leader>cs",
					"<cmd>Trouble symbols toggle focus=false<cr>",
					desc = "Symbols (Trouble)",
				},
				{
					"<leader>cl",
					"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
					desc = "LSP Definitions / references / ... (Trouble)",
				},
				{
					"<leader>xL",
					"<cmd>Trouble loclist toggle<cr>",
					desc = "Location List (Trouble)",
				},
				{
					"<leader>xQ",
					"<cmd>Trouble qflist toggle<cr>",
					desc = "Quickfix List (Trouble)",
				},
			},
		}),

	-- toggle term
	unless_vscode({
		'akinsho/toggleterm.nvim',
		version = "*",
		opts = {
			size = 120,
			open_mapping = [[<C-\>]], -- toggles the terminal window
			direction = 'vertical',
			shade_terminals = true,
			start_in_insert = true,
			insert_mappings = true,
			terminal_mappings = true,
			persist_size = true,
			persist_mode = true,
			close_on_exit = true,
		},
		config = function(_, opts)
			require("toggleterm").setup(opts)

			-- Terminal navigation with Ctrl+h/j/k/l from terminal mode
			local function tmap(lhs, rhs)
				vim.keymap.set('t', lhs, rhs, { noremap = true, silent = true })
			end

			-- Use <C-h/j/k/l> directly instead of <C-w>h/j/k/l
			tmap('<C-h>', [[<C-\><C-n><C-w>h]])
			tmap('<C-j>', [[<C-\><C-n><C-w>j]])
			tmap('<C-k>', [[<C-\><C-n><C-w>k]])
			tmap('<C-l>', [[<C-\><C-n><C-w>l]])

			-- Auto-start insert mode when entering terminal buffers
			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = "term://*",
				callback = function()
					if vim.bo.buftype == "terminal" then
						vim.cmd("startinsert")
					end
				end,
			})
		end,


	}),

	-- persistence for automatic session mgmt
	unless_vscode({
		"folke/persistence.nvim",
		event = "BufReadPre",             -- only start session saving when an actual file was opened
		opts = {
			dir = vim.fn.stdpath("state") .. "/sessions/", -- directory where session files are saved
			-- minimum number of file buffers that need to be open to save
			-- Set to 0 to always save
			need = 1,
			branch = true, -- use git branch to save session
		}
	}),

	unless_vscode({
		"stevearc/oil.nvim",
		dependencies = { { "echasnovski/mini.icons", opts = {} } },
		lazy = false,
		opts = {
			default_file_explorer = true, -- only triggers when opening a directory (e.g., `nvim .`)
		},
		keys = {
			{ "-", "<cmd>Oil<CR>", desc = "Open parent directory with Oil" },
		},
	}),

	-- Theme
	unless_vscode({
		-- Need a treesitter based colorscheme for markview to work properly
		-- Choose from: https://github.com/nvim-treesitter/nvim-treesitter/wiki/Colorschemes
		-- "Mofiqul/dracula.nvim",
		-- name = "dracula",
		"navarasu/onedark.nvim",
		name = "onedark",
		config = function()
			-- theme should be applied first, then remove background, etc for transparency
			-- vim.cmd("colorscheme dracula")
			vim.cmd("colorscheme onedark")

			-- Neovide-specific transparency config (not working on my mac :/ )
			if vim.g.neovide then
				vim.g.transparency = 0.8
				local alpha = function()
					return string.format("%02x", math.floor(255 * (vim.g.transparency or 0.8)))
				end

				vim.g.neovide_background_color = "#0f1117" .. alpha()
				vim.g.neovide_opacity = 1.0 -- or nil / just remove this line
			end

			-- Transparent backgrounds
			local groups = {
				"Normal", "NormalNC", "NormalFloat",
				"FloatBorder", "SignColumn", "VertSplit"
			}

			for _, group in ipairs(groups) do
				vim.api.nvim_set_hl(0, group, { bg = "none" })
			end

			-- override the cursor color after the theme loads
			-- something easily visible, like magenta (or orange for dracula)
			vim.api.nvim_set_hl(0, "Cursor", { fg = "#000000", bg = "#FF00FF" }) -- magenta
			-- vim.api.nvim_set_hl(0, "Cursor", { fg = "#000000", bg = "#FFA500" }) -- orange

			-- vim.opt.fillchars:append({ eob = "." })  -- or another char
			vim.api.nvim_set_hl(0, "EndOfBuffer", {
				fg = "#44475a", -- Dracula gray or equivalent subtle tone
				bg = "none"
			})

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
	}),

	-- Treesitter
	unless_vscode({
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = { "lua", "python", "vim", "markdown", "markdown_inline", "yaml", "latex" },
				highlight = { enable = true },
				modules = {},
				sync_install = false,
				ignore_install = {},
				auto_install = true,
			})
		end
	}),

	unless_vscode({
		-- TODO: try out https://github.com/gorbit99/codewindow.nvim
		-- requires code-minimap to be installed on your system
		'wfxr/minimap.vim',
	}),

	-- Comments
	-- gcc to comment/uncomment
	-- gc in visual mode
	unless_vscode({
		'numToStr/Comment.nvim',
		event = 'VeryLazy',
		config = function()
			require('Comment').setup()
		end,
	}),

	-- requires the vivify pkg installed
	--
	unless_vscode({ "jannis-baum/vivify.vim" }),

	-- Telescope (fuzzy finder)
	unless_vscode({
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
		},
		cmd = "Telescope",
		config = function()
			local actions = require("telescope.actions")
			local action_state = require("telescope.actions.state")

			local function delete_buffer_and_refresh(prompt_bufnr)
				local current_picker = action_state.get_current_picker(prompt_bufnr)
				if not current_picker then return end
				local selected_buf = action_state.get_selected_entry()
				vim.api.nvim_buf_delete(selected_buf.bufnr, { force = false })
				actions.close(prompt_bufnr)
				require("telescope.builtin").buffers()
			end

			local function safe_close(prompt_bufnr)
				local picker = action_state.get_current_picker(prompt_bufnr)
				if picker then actions.close(prompt_bufnr) end
			end

			local function open_buffer_in_vsplit(prompt_bufnr)
				local selected_buf = action_state.get_selected_entry()
				if selected_buf then
					vim.cmd("vsplit | buffer " .. selected_buf.bufnr)
					safe_close(prompt_bufnr)
				end
			end

			local function open_buffer_in_split(prompt_bufnr)
				local selected_buf = action_state.get_selected_entry()
				if selected_buf then
					vim.cmd("split | buffer " .. selected_buf.bufnr)
					safe_close(prompt_bufnr)
				end
			end

			require("telescope").setup({
				defaults = {
					prompt_prefix = "> ",
					selection_caret = " ",
					path_display = { "smart" },
					layout_config = {
						horizontal  = { width = 0.9, height = 0.9, prompt_position = "bottom", preview_cutoff = 120 },
						vertical    = { width = 0.9, height = 0.9, prompt_position = "bottom", preview_cutoff = 40 },
						center      = { width = 0.5, height = 0.4, prompt_position = "top", preview_cutoff = 40 },
						cursor      = { width = 0.8, height = 0.9, preview_cutoff = 40 },
						bottom_pane = { height = 25, prompt_position = "top", preview_cutoff = 120 },
					},
				},
				pickers = {
					buffers = {
						mappings = {
							i = {
								["<C-d>"] = delete_buffer_and_refresh,
							},
							n = {
								["dd"] = delete_buffer_and_refresh,
								["<Space>"] = actions.toggle_selection +
								    actions.move_selection_worse,
								["v"] = open_buffer_in_vsplit,
								["s"] = open_buffer_in_split,
							},
						},
					},
				},
				extensions = {
					["ui-select"] = require("telescope.themes").get_dropdown(),
				},
			})

			-- Load extensions
			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")

			-- Git-rooted live grep
			local function find_git_root()
				local file = vim.api.nvim_buf_get_name(0)
				local dir = (file == "") and vim.fn.getcwd() or vim.fn.fnamemodify(file, ":h")
				local git_root = vim.fn.systemlist("git -C " ..
					vim.fn.escape(dir, " ") .. " rev-parse --show-toplevel")[1]
				if vim.v.shell_error ~= 0 then return vim.fn.getcwd() end
				return git_root
			end

			local function live_grep_git_root()
				local root = find_git_root()
				require("telescope.builtin").live_grep({ search_dirs = { root } })
			end

			vim.api.nvim_create_user_command("LiveGrepGitRoot", live_grep_git_root, {})
		end,
	}),

	-- Gitsigns
	unless_vscode({
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("gitsigns").setup()
		end
	}),

	-- vim-table-mode
	unless_vscode({
		"dhruvasagar/vim-table-mode",
		cmd = "TableModeToggle", -- Lazy-load when you actually call :TableModeToggle
		config = function()
			-- typical corner character:
			vim.g.table_mode_corner = "|"
		end,
	}),



	-- markview (view yaml, markdown, etc in a browser)
	unless_vscode({
		"OXY2DEV/markview.nvim",
		-- No `ft` or `event` here; it loads at startup
		config = function()
			require("markview").setup({
				auto_start = false,
				auto_close = false,
				dark_theme = true,
				preview = {
					enable = false,
				},
			})
		end,
	}),


	unless_vscode({
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = "cd app && npm install",
		config = function()
			vim.g.mkdp_auto_start = 0
			vim.g.mkdp_echo_preview_url = 1
			vim.g.mkdp_browser = "firefox" -- or set to "firefox", etc.
		end,
	}),

	-- Autocompletion
	unless_vscode({
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
	}),

	-- Mason (for easy LSP/tool installation)
	unless_vscode({
		"williamboman/mason.nvim",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			"neovim/nvim-lspconfig",
			-- neovim lua dev detup w/ smart LSP configs and types
			"folke/neodev.nvim",
		},
		config = function()
			-- neodev must be before lua_ls is set up
			require("neodev").setup()

			require("mason").setup()
			require("mason-lspconfig").setup()

			local servers = {
				pylsp = {
					plugins = {
						ruff = {
							enabled = true,
							formatEnabled = true,
							extendSelect = { "I" },
							targetVersion = "py310",
						},
					},
				},

				lua_ls = (function()
					local function optional_path(path)
						local stat = vim.loop.fs_stat(path)
						if stat and stat.type == "directory" then
							return path
						end
						return nil
					end

					local hammerspoon_paths = vim.tbl_filter(function(p)
						return p ~= nil
					end, {
						optional_path(vim.fn.expand("~/.local/share/hammerspoon-api/extensions")),
						optional_path(vim.fn.expand(
							"~/.local/share/hammerspoon-api/extensions/hs")),
						optional_path(vim.fn.expand(
							"~/.local/share/hammerspoon-api/extensions/hs/alert")),
					})

					return {
						Lua = {
							diagnostics = {
								globals = { "hs" }, -- avoid "undefined global 'hs'"
							},
							workspace = {
								checkThirdParty = false,
								library = hammerspoon_paths,
							},
							telemetry = { enable = false },
						}
					}
				end)(),
				marksman = {}, -- No special config needed
			}

			-- Broadcast cmp-nvim-lsp capabilities
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Shared on_attach
			local on_attach = function(client, bufnr)
				-- Local format command
				vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
					vim.lsp.buf.format({ async = false })
				end, { desc = "Format buffer with LSP" })

				vim.api.nvim_create_autocmd("BufWritePre", {
					buffer = bufnr,
					callback = function()
						local client_with_format = nil
						for _, client in ipairs(vim.lsp.get_active_clients({ bufnr = bufnr })) do
							if client.supports_method("textDocument/formatting") then
								client_with_format = client
								break
							end
						end

						if client_with_format then
							vim.lsp.buf.format({
								async = false,
								filter = function(c)
									return c.id == client_with_format.id
								end,
							})
						end
					end,
				})


				-- Special case: Ruff fixAll on save (only for Ruff client)
				if client.name == "pylsp" or client.name == "ruff" then
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = vim.api.nvim_create_augroup("RuffFixAllOnSave", { clear = true }),
						buffer = bufnr,
						callback = function()
							vim.lsp.buf.code_action({
								context = {
									only = { "source.fixAll.ruff" },
									diagnostics = {},
								},
								apply = true,
							})
						end,
					})
				end
			end

			-- Ensure all listed servers are installed
			local mason_lspconfig = require("mason-lspconfig")
			mason_lspconfig.setup {
				ensure_installed = vim.tbl_keys(servers),
				automatic_installation = true,
			}

			-- Set up each server with its config
			mason_lspconfig.setup_handlers {
				function(server_name)
					require("lspconfig")[server_name].setup {
						capabilities = capabilities,
						on_attach = on_attach,
						settings = servers[server_name],
						filetypes = servers[server_name] and servers[server_name].filetypes,
					}
				end,
			}
		end,
	}),



})

-- Define the command globally (one time only)
if not vim.g._python_commands_defined then
	vim.api.nvim_create_user_command("InsertCommandlineProgram", function()
		if vim.bo.filetype ~= "python" then
			vim.notify("InsertCommandlineProgram is only for Python buffers", vim.log.levels.WARN)
			return
		end

		-- Insert the file contents just above the current line
		vim.cmd('silent .-1read ~/.config/nvim/ftplugin/python-fragments/commandline_program.py')
	end, {
		desc = "Insert a basic argparse command-line program template",
	})
	vim.g._python_commands_defined = true
end

-- Python-specific ftplugin configuration inside init.lua
vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		-- Abbreviations
		local abbrevs = {
			improt = "import",
			imrpot = "import",
			imrpt = "import",
			imprt = "import",
			iport = "import",
			impot = "import",
			impowt = "import",
			imropt = "import",
			ipt = "import",
			ii = "import",
			prtin = "print",
		}
		for k, v in pairs(abbrevs) do
			vim.cmd(string.format("iabbrev %s %s", k, v))
		end

		-- Mappings
		-- vim.keymap.set("n", ",O", "<Esc>:w<CR>:!pre-commit run --files %<CR>", { buffer = true })
		-- vim.keymap.set("n", ",o", "<Esc>:w<CR>:!ruff check --fix %<CR>", { buffer = true })

		vim.keymap.set("n", ",B", "Obreakpoint()<Esc>0w", { buffer = true })
		vim.keymap.set("n", "]]", [[/^\s*class\|^\s*def<CR>]], { buffer = true })
		vim.keymap.set("n", "[[", [[?^\s*class\|^\s*def<CR>]], { buffer = true })
	end,
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


if not is_vscode then
	-- Telescope bindings
	local tlscope = require("telescope.builtin")
	vim.keymap.set("n", "<leader>?", tlscope.oldfiles, { desc = "[?] Recently opened files" })
	vim.keymap.set("n", "<leader>ff", tlscope.buffers, { desc = "[ ] Find existing buffers" })
	vim.keymap.set("n", "<leader>fb", tlscope.find_files, { desc = "[F]ind [B]y Name" })
	vim.keymap.set("n", "<leader>fh", tlscope.help_tags, { desc = "[F]ind [H]elp" })
	vim.keymap.set("n", "<leader>fs", tlscope.grep_string, { desc = "[F]ind [S]tring under cursor" })
	vim.keymap.set("n", "<leader>gf", tlscope.git_files, { desc = "Git files" })
	vim.keymap.set("n", "<leader>sd", tlscope.diagnostics, { desc = "Diagnostics" })
	vim.keymap.set("n", "<leader>sr", tlscope.resume, { desc = "Resume last picker" })

	vim.keymap.set("n", "<leader>sG", ":LiveGrepGitRoot<CR>", { desc = "[S]earch by [G]rep in Git root" })

	vim.keymap.set("n", "<leader>/", function()
		tlscope.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
			winblend = 10,
			previewer = false,
		}))
	end, { desc = "[/] Search in current buffer" })

	vim.keymap.set("n", "<leader>ss", tlscope.builtin, { desc = "[S]elect Telescope function" })
	vim.keymap.set("n", "<leader>s/", function()
		tlscope.live_grep({ grep_open_files = true, prompt_title = "Live Grep in Open Files" })
	end, { desc = "[S]earch [/] in Open Files" })


	-- persistence/session bindings
	-- load the session for the current directory
	vim.keymap.set("n", "<leader>qs", function() require("persistence").load() end)
	-- select a session to load
	vim.keymap.set("n", "<leader>qS", function() require("persistence").select() end)
	-- load the last session
	vim.keymap.set("n", "<leader>ql", function() require("persistence").load({ last = true }) end)
	-- stop Persistence => session won't be saved on exit
	vim.keymap.set("n", "<leader>qd", function() require("persistence").stop() end)


	-- minimap bindings
	vim.api.nvim_set_keymap('n', '<leader>mm', ':MinimapToggle<CR>',
		{ noremap = true, silent = true, desc = 'Toggle Minimap' })

	-- escape from terminal mode (i.e., insert on terminal line) to browse terminal
	-- hit 'i' to enter the terminal mode again
	vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]])

	-- navigate between windows with <ctrl><KEY>
	vim.keymap.set('n', '<C-h>', '<C-w>h', { noremap = true, silent = true })
	vim.keymap.set('n', '<C-j>', '<C-w>j', { noremap = true, silent = true })
	vim.keymap.set('n', '<C-k>', '<C-w>k', { noremap = true, silent = true })
	vim.keymap.set('n', '<C-l>', '<C-w>l', { noremap = true, silent = true })
	vim.keymap.set('i', '<C-h>', '<Esc><C-w>h', { noremap = true, silent = true })
	vim.keymap.set('i', '<C-j>', '<Esc><C-w>j', { noremap = true, silent = true })
	vim.keymap.set('i', '<C-k>', '<Esc><C-w>k', { noremap = true, silent = true })
	vim.keymap.set('i', '<C-l>', '<Esc><C-w>l', { noremap = true, silent = true })
end


-- py2nb syntax highlighting (modern Neovim Lua API)
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.py",
	callback = function()
		vim.cmd([[
      syntax match Comment "#|.*$"
      syntax match Special "#!.*$"
      syntax match Delimiter "#-.*$"
    ]])
	end,
})

---------------------------
-- Auto-formatting on Save
---------------------------
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.lua",
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
