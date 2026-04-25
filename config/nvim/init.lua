---------------------------------------------------------------------------
-- init.lua (single-file config, Neovim 0.12+ with vim.pack)
-- Author: J.T. Prince
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- Early settings / bootstrapping
---------------------------------------------------------------------------
-- If you have heavy modules, enabling the Lua loader can speed startup
pcall(function()
	vim.loader.enable()
end)

require("early_init")

vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Ensure proper colors in Neovide and terminal
vim.opt.termguicolors = true
vim.g.neovide_hide_titlebar = true

---------------------------------------------------------------------------
-- Neovide settings
---------------------------------------------------------------------------
if vim.g.neovide then
	vim.g.neovide_scale_factor = 1.1
	vim.g.neovide_scroll_animation_length = 0.00
	vim.g.neovide_cursor_animate_in_insert_mode = false
	vim.g.neovide_repeat_rate = 20
	vim.g.neovide_refresh_rate = 144
	vim.g.neovide_cursor_animation_length = 0
	vim.g.neovide_floating_blur_amount_x = 0.0
	vim.g.neovide_floating_blur_amount_y = 0.0
	vim.g.neovide_input_use_logo = false
end

---------------------------------------------------------------------------
-- VS Code check
---------------------------------------------------------------------------
local is_vscode = vim.g.vscode ~= nil

---------------------------------------------------------------------------
-- Clipboard: Always use system clipboard (plus special Neovide Cmd bindings)
---------------------------------------------------------------------------
vim.opt.clipboard:append("unnamedplus")

if vim.g.neovide then
	-- Cmd+C / Cmd+V / Cmd+X in Neovide
	vim.keymap.set("v", "<D-c>", '"+y', { noremap = true, silent = true, desc = "Copy (system clipboard)" })
	vim.keymap.set("n", "<D-c>", '"+yy', { noremap = true, silent = true, desc = "Copy line (system clipboard)" })

	vim.keymap.set({ "n", "v" }, "<D-v>", '"+p', { noremap = true, silent = true, desc = "Paste (system clipboard)" })
	vim.keymap.set("i", "<D-v>", "<C-r>+", { noremap = true, silent = true, desc = "Paste (system clipboard)" })
	vim.keymap.set("c", "<D-v>", "<C-R>+", { noremap = true, silent = true, desc = "Paste (system clipboard)" })

	vim.keymap.set("v", "<D-x>", '"+d', { noremap = true, silent = true, desc = "Cut (system clipboard)" })
	vim.keymap.set("n", "<D-x>", '"+dd', { noremap = true, silent = true, desc = "Cut line (system clipboard)" })
else
	-- Terminal: If you want Cmd+key behavior, do it in your terminal config (Alacritty/Kitty/etc.)
end

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
			"-e",
			"on run argv",
			"-e",
			"set the clipboard to (read (POSIX file (item 1 of argv)) as «class HTML»)",
			"-e",
			"end run",
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

---------------------------------------------------------------------------
-- Plugins (vim.pack — built-in plugin manager, Neovim 0.12+)
---------------------------------------------------------------------------
if not is_vscode then
	-- Build hooks for plugins that need post-install work.
	-- Must be registered BEFORE vim.pack.add() so the first install runs them.
	vim.api.nvim_create_autocmd("PackChanged", {
		group = vim.api.nvim_create_augroup("user_pack_build", { clear = true }),
		callback = function(args)
			local d = args.data
			if d.kind == "delete" then return end
			local name = (d.spec and d.spec.name) or vim.fn.fnamemodify(d.path, ":t")

			if name == "nvim-treesitter" then
				vim.schedule(function() vim.cmd("TSUpdate") end)
			elseif name == "telescope-fzf-native.nvim" then
				vim.notify("Building telescope-fzf-native…", vim.log.levels.INFO)
				vim.system({ "make" }, { cwd = d.path }):wait()
			elseif name == "markdown-preview.nvim" then
				vim.notify("Installing markdown-preview deps…", vim.log.levels.INFO)
				vim.system({ "npm", "install" }, { cwd = d.path .. "/app" }):wait()
			end
		end,
	})

	vim.pack.add({
		-- UI / appearance
		"https://github.com/navarasu/onedark.nvim",
		"https://github.com/echasnovski/mini.icons",
		"https://github.com/stevearc/oil.nvim",
		"https://github.com/wfxr/minimap.vim",
		-- editing
		"https://github.com/numToStr/Comment.nvim",
		"https://github.com/dhruvasagar/vim-table-mode",
		"https://github.com/lewis6991/gitsigns.nvim",
		"https://github.com/folke/persistence.nvim",
		"https://github.com/akinsho/toggleterm.nvim",
		"https://github.com/cameron-wags/rainbow_csv.nvim",
		"https://github.com/folke/trouble.nvim",
		"https://github.com/jtprince/cursor-nvim-plugin",
		"https://github.com/jannis-baum/vivify.vim",
		-- treesitter (main branch uses the new install API)
		{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
		-- telescope
		"https://github.com/nvim-lua/plenary.nvim",
		"https://github.com/nvim-telescope/telescope.nvim",
		"https://github.com/nvim-telescope/telescope-fzf-native.nvim",
		-- markdown
		"https://github.com/OXY2DEV/markview.nvim",
		"https://github.com/iamcco/markdown-preview.nvim",
		-- completion
		"https://github.com/L3MON4D3/LuaSnip",
		"https://github.com/hrsh7th/cmp-nvim-lsp",
		"https://github.com/hrsh7th/cmp-buffer",
		"https://github.com/hrsh7th/cmp-path",
		"https://github.com/saadparwaiz1/cmp_luasnip",
		"https://github.com/hrsh7th/nvim-cmp",
		-- LSP
		"https://github.com/williamboman/mason.nvim",
		"https://github.com/williamboman/mason-lspconfig.nvim",
		"https://github.com/neovim/nvim-lspconfig",
		"https://github.com/folke/lazydev.nvim",
	})

	-------------------------------------------------------------------------
	-- Theme: onedark (configure first so highlights are set early)
	-------------------------------------------------------------------------
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

	-------------------------------------------------------------------------
	-- mini.icons / oil
	-------------------------------------------------------------------------
	require("mini.icons").setup()
	require("oil").setup({ default_file_explorer = true })
	vim.keymap.set("n", "-", "<cmd>Oil<CR>", { desc = "Open parent directory (Oil)" })

	-------------------------------------------------------------------------
	-- Editing plugins
	-------------------------------------------------------------------------
	require("Comment").setup()
	vim.g.table_mode_corner = "|"
	require("gitsigns").setup()

	require("persistence").setup({
		dir = vim.fn.stdpath("state") .. "/sessions/",
		need = 1,
		branch = true,
	})

	require("rainbow_csv").setup()

	require("trouble").setup()
	for _, m in ipairs({
		{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",                        "Diagnostics (Trouble)" },
		{ "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",           "Buffer Diagnostics (Trouble)" },
		{ "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>",                "Symbols (Trouble)" },
		{ "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", "LSP List (Trouble)" },
		{ "<leader>xL", "<cmd>Trouble loclist toggle<cr>",                            "Location List (Trouble)" },
		{ "<leader>xQ", "<cmd>Trouble qflist toggle<cr>",                             "Quickfix List (Trouble)" },
	}) do
		vim.keymap.set("n", m[1], m[2], { silent = true, desc = m[3] })
	end

	-------------------------------------------------------------------------
	-- ToggleTerm
	-------------------------------------------------------------------------
	require("toggleterm").setup({
		size = 120,
		open_mapping = [[<C-\>]],
		direction = "vertical",
		shade_terminals = true,
		start_in_insert = true,
		insert_mappings = true,
		terminal_mappings = true,
		persist_size = true,
		persist_mode = true,
		close_on_exit = true,
	})

	for _, m in ipairs({
		{ "<C-h>", [[<C-\><C-n><C-w>h]], "Terminal: focus left" },
		{ "<C-j>", [[<C-\><C-n><C-w>j]], "Terminal: focus down" },
		{ "<C-k>", [[<C-\><C-n><C-w>k]], "Terminal: focus up" },
		{ "<C-l>", [[<C-\><C-n><C-w>l]], "Terminal: focus right" },
	}) do
		vim.keymap.set("t", m[1], m[2], { noremap = true, silent = true, desc = m[3] })
	end

	vim.api.nvim_create_autocmd("BufEnter", {
		pattern = "term://*",
		callback = function()
			if vim.bo.buftype == "terminal" then
				vim.cmd("startinsert")
			end
		end,
	})

	-------------------------------------------------------------------------
	-- Treesitter
	-------------------------------------------------------------------------
	require("nvim-treesitter").setup()
	pcall(function()
		require("nvim-treesitter").install({
			"lua", "python", "vim", "vimdoc", "markdown", "markdown_inline", "yaml", "latex",
		})
	end)

	-------------------------------------------------------------------------
	-- Markdown
	-------------------------------------------------------------------------
	require("markview").setup({
		auto_start = false,
		auto_close = false,
		dark_theme = true,
		preview = { enable = false },
	})

	vim.g.mkdp_auto_start = 0
	vim.g.mkdp_echo_preview_url = 1
	vim.g.mkdp_browser = "firefox"

	-------------------------------------------------------------------------
	-- Telescope
	-------------------------------------------------------------------------
	do
		local actions = require("telescope.actions")
		local action_state = require("telescope.actions.state")

		local function delete_buffer_and_refresh(prompt_bufnr)
			local selected_buf = action_state.get_selected_entry()
			if not selected_buf then return end
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
				selection_caret = " ",
				path_display = { "smart" },
				layout_config = {
					horizontal = { width = 0.9, height = 0.9, prompt_position = "bottom", preview_cutoff = 120 },
					vertical = { width = 0.9, height = 0.9, prompt_position = "bottom", preview_cutoff = 40 },
					center = { width = 0.5, height = 0.4, prompt_position = "top", preview_cutoff = 40 },
					cursor = { width = 0.8, height = 0.9, preview_cutoff = 40 },
					bottom_pane = { height = 25, prompt_position = "top", preview_cutoff = 120 },
				},
			},
			pickers = {
				buffers = {
					mappings = {
						i = { ["<C-d>"] = delete_buffer_and_refresh },
						n = {
							["dd"] = delete_buffer_and_refresh,
							["<Space>"] = actions.toggle_selection + actions.move_selection_worse,
							["v"] = open_buffer_in_vsplit,
							["s"] = open_buffer_in_split,
						},
					},
				},
			},
		})

		pcall(require("telescope").load_extension, "fzf")

		local function find_git_root()
			local file = vim.api.nvim_buf_get_name(0)
			local dir = (file == "") and vim.fn.getcwd() or vim.fn.fnamemodify(file, ":h")
			local root = vim.fn.systemlist("git -C " ..
				vim.fn.escape(dir, " ") .. " rev-parse --show-toplevel")[1]
			if vim.v.shell_error ~= 0 then return vim.fn.getcwd() end
			return root
		end

		vim.api.nvim_create_user_command("LiveGrepGitRoot", function()
			require("telescope.builtin").live_grep({ search_dirs = { find_git_root() } })
		end, {})
	end

	-------------------------------------------------------------------------
	-- Completion: nvim-cmp
	-------------------------------------------------------------------------
	do
		local cmp = require("cmp")
		cmp.setup({
			snippet = {
				expand = function(args)
					require("luasnip").lsp_expand(args.body)
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<Tab>"] = cmp.mapping.select_next_item(),
				["<S-Tab>"] = cmp.mapping.select_prev_item(),
				["<CR>"] = cmp.mapping.confirm({ select = true }),
			}),
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "luasnip" },
				{ name = "buffer" },
				{ name = "path" },
			}),
		})
	end

	-------------------------------------------------------------------------
	-- Mason + LSP (Neovim 0.11+ native config)
	-------------------------------------------------------------------------
	require("lazydev").setup({})
	require("mason").setup()

	do
		local servers = {
			pylsp = {
				settings = {
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
				},
			},

			lua_ls = (function()
				local function optional_path(path)
					local stat = vim.uv.fs_stat(path)
					if stat and stat.type == "directory" then
						return path
					end
					return nil
				end

				local hammerspoon_paths = vim.tbl_filter(function(p)
					return p ~= nil
				end, {
					optional_path(vim.fn.expand("~/.local/share/hammerspoon-api/extensions")),
					optional_path(vim.fn.expand("~/.local/share/hammerspoon-api/extensions/hs")),
					optional_path(vim.fn.expand("~/.local/share/hammerspoon-api/extensions/hs/alert")),
				})

				return {
					settings = {
						Lua = {
							diagnostics = { globals = { "hs" } },
							workspace = {
								checkThirdParty = false,
								library = hammerspoon_paths,
							},
							telemetry = { enable = false },
						},
					},
				}
			end)(),

			marksman = {},
		}

		local capabilities = require("cmp_nvim_lsp").default_capabilities()

		local on_attach = function(client, bufnr)
			vim.api.nvim_buf_create_user_command(bufnr, "Format", function()
				vim.lsp.buf.format({ async = false })
			end, { desc = "Format buffer with LSP" })

			local group = vim.api.nvim_create_augroup("LspOnSave_" .. bufnr, { clear = true })

			if client:supports_method("textDocument/formatting") then
				vim.api.nvim_create_autocmd("BufWritePre", {
					group = group,
					buffer = bufnr,
					callback = function()
						vim.lsp.buf.format({
							async = false,
							bufnr = bufnr,
							filter = function(c) return c.id == client.id end,
						})
					end,
				})
			end

			-- Ruff fixAll on save (only applies if ruff LSP is attached)
			if client.name == "ruff" then
				vim.api.nvim_create_autocmd("BufWritePre", {
					group = group,
					buffer = bufnr,
					callback = function()
						vim.lsp.buf.code_action({
							context = { only = { "source.fixAll.ruff" }, diagnostics = {} },
							apply = true,
						})
					end,
				})
			end
		end

		require("mason-lspconfig").setup({
			ensure_installed = vim.tbl_keys(servers),
		})

		for server_name, config in pairs(servers) do
			vim.lsp.config(server_name, vim.tbl_deep_extend("force", {
				capabilities = capabilities,
				on_attach = on_attach,
			}, config or {}))
			vim.lsp.enable(server_name)
		end
	end
end

---------------------------------------------------------------------------
-- User commands / filetype setup
---------------------------------------------------------------------------

-- Define this command globally once
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

---------------------------------------------------------------------------
-- Python-specific behavior
---------------------------------------------------------------------------
-- NOTE: This whole block would be very cleanly moved into:
--   ~/.config/nvim/ftplugin/python.lua
-- Neovim automatically loads that file for Python buffers.
vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
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

		vim.keymap.set("n", ",B", "Obreakpoint()<Esc>0w", { buffer = true, desc = "Insert breakpoint()" })
		vim.keymap.set("n", "]]", [[/^\s*\(class\|def\)\s<CR>]], { buffer = true, desc = "Next class/def" })
		vim.keymap.set("n", "[[", [[?^\s*\(class\|def\)\s<CR>]], { buffer = true, desc = "Prev class/def" })
	end,
})

---------------------------------------------------------------------------
-- Additional keymaps, basic settings, etc.
---------------------------------------------------------------------------
vim.opt.hlsearch = true
vim.opt.hidden = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wrap = true

-- windows
vim.opt.equalalways = false
vim.opt.winminwidth = 10
vim.opt.winwidth = 80

---------------------------------------------------------------------------
-- Non-VSCode keymaps
---------------------------------------------------------------------------
if not is_vscode then
	local tlscope = require("telescope.builtin")

	vim.keymap.set("n", "<leader>?", tlscope.oldfiles, { desc = "[?] Recently opened files" })
	vim.keymap.set("n", "<leader>ff", tlscope.buffers, { desc = "[F]ind existing buffers" })
	vim.keymap.set("n", "<leader>fb", tlscope.find_files, { desc = "[F]ind [B]y name" })
	vim.keymap.set("n", "<leader>fh", tlscope.help_tags, { desc = "[F]ind [H]elp" })
	vim.keymap.set("n", "<leader>fs", tlscope.grep_string, { desc = "[F]ind [S]tring under cursor" })
	vim.keymap.set("n", "<leader>gf", tlscope.git_files, { desc = "[G]it [F]iles" })
	vim.keymap.set("n", "<leader>sd", tlscope.diagnostics, { desc = "[S]how [D]iagnostics" })
	vim.keymap.set("n", "<leader>sr", tlscope.resume, { desc = "[S]earch [R]esume" })
	vim.keymap.set("n", "<leader>sG", "<cmd>LiveGrepGitRoot<CR>", { desc = "[S]earch [G]rep in Git root" })

	vim.keymap.set("n", "<leader>/", function()
		tlscope.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
			winblend = 10,
			previewer = false,
		}))
	end, { desc = "[/] Fuzzy search current buffer" })

	vim.keymap.set("n", "<leader>ss", tlscope.builtin, { desc = "[S]elect Telescope picker" })
	vim.keymap.set("n", "<leader>s/", function()
		tlscope.live_grep({ grep_open_files = true, prompt_title = "Live Grep in Open Files" })
	end, { desc = "[S]earch [/] in Open Files" })

	-- persistence
	vim.keymap.set("n", "<leader>qs", function() require("persistence").load() end, { desc = "Session load (cwd)" })
	vim.keymap.set("n", "<leader>qS", function() require("persistence").select() end, { desc = "Session select" })
	vim.keymap.set("n", "<leader>ql", function() require("persistence").load({ last = true }) end,
		{ desc = "Session load (last)" })
	vim.keymap.set("n", "<leader>qd", function() require("persistence").stop() end, { desc = "Session stop saving" })

	-- minimap
	vim.keymap.set("n", "<leader>mm", "<cmd>MinimapToggle<CR>", { silent = true, desc = "Toggle minimap" })

	-- terminal escape (browse terminal output)
	vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { silent = true, desc = "Terminal: normal mode" })

	-- window navigation
	vim.keymap.set("n", "<C-h>", "<C-w>h", { silent = true, desc = "Window left" })
	vim.keymap.set("n", "<C-j>", "<C-w>j", { silent = true, desc = "Window down" })
	vim.keymap.set("n", "<C-k>", "<C-w>k", { silent = true, desc = "Window up" })
	vim.keymap.set("n", "<C-l>", "<C-w>l", { silent = true, desc = "Window right" })

	vim.keymap.set("i", "<C-h>", "<Esc><C-w>h", { silent = true, desc = "Window left (insert)" })
	vim.keymap.set("i", "<C-j>", "<Esc><C-w>j", { silent = true, desc = "Window down (insert)" })
	vim.keymap.set("i", "<C-k>", "<Esc><C-w>k", { silent = true, desc = "Window up (insert)" })
	vim.keymap.set("i", "<C-l>", "<Esc><C-w>l", { silent = true, desc = "Window right (insert)" })
end

---------------------------------------------------------------------------
-- Custom syntax highlighting for py2nb comment conventions
---------------------------------------------------------------------------
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

---------------------------------------------------------------------------
-- Auto-formatting on Save (Lua only)
---------------------------------------------------------------------------
-- NOTE: This could be moved to ftplugin/lua.lua if you ever want.
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.lua",
	callback = function()
		vim.lsp.buf.format({ async = false })
	end,
})

---------------------------------------------------------------------------
-- Select all bindings (Cmd+A and Ctrl+G)
---------------------------------------------------------------------------
vim.keymap.set("n", "<D-a>", "ggVG", { silent = true, desc = "Select all" })
vim.keymap.set("i", "<D-a>", "<Esc>ggVG", { silent = true, desc = "Select all" })
vim.keymap.set("v", "<D-a>", "<Esc>ggVG", { silent = true, desc = "Select all" })

vim.keymap.set("n", "<C-g>", "ggVG", { silent = true, desc = "Select all" })
vim.keymap.set("i", "<C-g>", "<Esc>ggVG", { silent = true, desc = "Select all" })
vim.keymap.set("v", "<C-g>", "<Esc>ggVG", { silent = true, desc = "Select all" })

---------------------------------------------------------------------------
-- Semicolon behaves like colon
---------------------------------------------------------------------------
vim.keymap.set("n", ";", ":", { noremap = true, desc = "Command-line (colon)" })
