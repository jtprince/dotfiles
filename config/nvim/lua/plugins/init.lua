-- Plugin manager: vim.pack (Neovim 0.12+).
-- Installs plugins, registers build hooks, and orchestrates per-plugin setup.

-- Build hooks: must be registered BEFORE vim.pack.add() so first-install runs them.
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

-- Per-plugin setup, in load order.
require("plugins.ui")
require("plugins.editor")
require("plugins.treesitter")
require("plugins.telescope")
require("plugins.markdown")
require("plugins.lsp")
