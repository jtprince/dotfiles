---------------------------
-- Early settings
---------------------------
-- Ensure we have proper colors in both Neovide and terminal
vim.opt.termguicolors = true

-- If you're using Neovide, you might want some special settings:
if vim.g.neovide then
  vim.g.neovide_scale_factor = 1.1
  vim.g.neovide_scroll_animation_length = 0.3
end

---------------------------
-- VS Code check
---------------------------
-- The Neovim VSCode extension sets "vim.g.vscode = 1" or a truthy value.
-- We will conditionally load certain features if NOT running in VS Code.
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

if vim.g.neovide then
  -- Use Cmd+C to copy to the system clipboard
  vim.keymap.set("v", "<D-c>", '"+y', { noremap = true, silent = true })  -- Copy
  vim.keymap.set("n", "<D-c>", '"+yy', { noremap = true, silent = true }) -- Copy line

  -- Use Cmd+V to paste from the system clipboard
  vim.keymap.set({ "n", "v", "i" }, "<D-v>", '"+p', { noremap = true, silent = true })  -- Paste in normal/insert/visual mode
  vim.keymap.set("c", "<D-v>", "<C-R>+", { noremap = true, silent = true })  -- Paste in command mode (for ex: `:echo`)

  -- Use Cmd+X to cut to the system clipboard
  vim.keymap.set("v", "<D-x>", '"+d', { noremap = true, silent = true })  -- Cut in visual mode
  vim.keymap.set("n", "<D-x>", '"+dd', { noremap = true, silent = true }) -- Cut line in normal mode
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
        vim.cmd("colorscheme dracula")  -- Apply the theme first
  
        -- Now override the cursor color after the theme loads
        vim.api.nvim_set_hl(0, "Cursor", { fg = "#000000", bg = "#FFA500" })
  
        -- Ensure 'guicursor' is set correctly
        vim.opt.guicursor = "n-v-c:block-Cursor,i-ci-ve:ver25-Cursor,r-cr:hor20-Cursor,o:hor50-Cursor"
  
        -- Neovide-specific cursor settings
        if vim.g.neovide then
  	vim.g.neovide_cursor_vfx_mode = "railgun"  -- Optional visual effect
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
        ensure_installed = { "lua", "python", "vim" }, -- Add languages you need
        highlight = { enable = true },
      })
    end
  },

  -- Autocompletion
  (not is_vscode) and {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", -- LSP completion source
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",     -- Snippets
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
        ensure_installed = { "pyright" } -- Python LSP
      })

      -- Example LSP config
      local lspconfig = require("lspconfig")
      require("mason-lspconfig").setup_handlers({
        function(server_name)
          lspconfig[server_name].setup({
            capabilities = require("cmp_nvim_lsp").default_capabilities(),
          })
        end,
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
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.hlsearch = false
vim.opt.hidden = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- Keymap examples
-- <Space> as <Leader>
vim.g.mapleader = ","
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>",  { desc = "Live grep" })
