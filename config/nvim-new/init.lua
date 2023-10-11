local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
local opt = vim.opt

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
opt.rtp:prepend(lazypath)

require("lazy").setup({
    "williamboman/mason.nvim",
    -- popup with possible keybindings of what you started to type
    "folke/which-key.nvim",

    -- local and global nvim config in json
    {"folke/neoconf.nvim", cmd = "Neoconf" },

    -- plugin with signature help, docs, completion for nvim lua API
    "folke/neodev.nvim",

    -- provides vimp
    'svermeulen/vimpeccable',

    -- {
    --     "stevearc/gkeep.nvim",
    --     build = "UpdateRemotePlugins",
    --     -- opts = {}
    --     -- Optional dependencies
    --     dependencies = { "nvim-tree/nvim-web-devicons" },
    -- },
})

require("mason").setup()


-- always show statusline
opt.laststatus = 2

-- emit true, 24-bit color to the terminal
opt.termguicolors = true
opt.pumblend = 25
opt.winblend = 25

-- META LEVEL =================================================================

-- leader key
g.mapleader = ','

-- STATE ======================================================================

opt.shada = "!,'100,<50,s10,h"

-- GENERAL CONFIG =============================================================

-- if has("autocmd")
--     filetype plugin indent on
-- endif

opt.mousehide = true                -- hide the mouse when typing text
opt.mouse = "a"                     -- use your mouse in a terminal
opt.cmdheight = 1                   -- make command line one line high (default)
opt.backspace = "indent,eol,start"  -- backspace over autoindent, join lines, start of insert
opt.tabstop = 4                     -- spaces that <Tab> in file counts when displaying
opt.shiftwidth = 4                  -- number spaces to shift things
opt.textwidth = 78                  -- limit text width to 78
opt.autoindent = true               -- uses indent from the previous line
opt.softtabstop = 4                 -- soft tab stop
opt.expandtab = true                -- use spaces instead of tab (Ctrl-V<Tab> for real tab)
opt.ruler = true                    -- shows line and col number
opt.formatoptions = l               -- autoformating (l=long lines not broken on insert)
opt.guicursor="a:blinkon0"          -- disable cursor blink
opt.autoread = true                 -- reload files changed outside vim
opt.history = 1000                  -- size of command history
opt.fileformats="unix,dos,mac"      -- eol formats to try first

-- opt.guioptions-=m                 -- remove the menu bar
-- opt.guioptions-=T                 -- remove the gui toolbar
-- opt.guioptions-=r                 -- remove the right scrollbar

opt.list  = true
opt.listchars = {tab = "»·"}         -- Indicate tabs (so 2 tabs: »···»···)
opt.wrap = true                     -- Use word wrap by default
opt.title = true                    -- Window shows filename being edited
opt.completeopt = menu              -- Only show the popup menu, not the preview buffer
opt.foldlevel = 20                  -- Start with a deep foldlevel
-- virtualedit = all breaks some expected functionality, so best to use on demand
-- set virtualedit = all          -- let's cursor move around freely, great for md tables

-- NOTE: Holding down SHIFT enables before mousing over a selection enables
-- a terminal to grab the selection for pasting

-- vimp is shorthand for vimpeccable
local vimp = require('vimp')

-- use semicolon for all colon commands
vimp.nnoremap(";", ":")

-- example function
-- vimp.nnoremap('<leader>hw', function()
--  print('hello')
--  print('world')
-- end)

-- Toggle line numbers
vimp.nnoremap('<leader>n', function()
  vim.wo.number = not vim.wo.number
end)

-- Keep the cursor in place while joining lines
-- vimp.nnoremap('J', 'mzJ`z')

-- vimp.nnoremap('<leader>ev', ':vsplit ~/.config/nvim/init.lua<cr>')
-- Or:
-- vimp.nnoremap('<leader>ev', [[:vsplit ~/.config/nvim/init.lua<cr>]])
-- Or:
-- vimp.nnoremap('<leader>ev', function()
--   vim.cmd('vsplit ~/.config/nvim/init.lua')
-- end)


-- vimp.noremap("hh", "gg")
-- vimp.noremap("gg", "<Nop>")
vimp.noremap("s", "h")
vimp.noremap("g", "l")
vimp.noremap("d", "k")
vimp.noremap("f", "j")
vimp.noremap("h", "g")
vimp.noremap("l", "s")
vimp.noremap("k", "d")
vimp.noremap("j", "f")
vimp.noremap("F", "<PAGEDOWN>M")
vimp.noremap("D", "<PAGEUP>M")

-- https://www.reddit.com/r/neovim/comments/12aek0y/ai_plugin_overview/
-- Top ones to explore:
-- https://github.com/dpayne/CodeGPT.nvim
-- copilot.lua
-- https://github.com/Bryley/neoai.nvim
-- https://github.com/jackMort/ChatGPT.nvim
-- https://github.com/james1236/backseat.nvim
