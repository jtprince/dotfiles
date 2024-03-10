-- Options
-- See `:help vim.o`

-- window specific (old school)
local wo = vim.wo

-- vim options (old school more direct interface)
local o = vim.o

-- unified lua way to set uptions (i.e., returns tables, not strings where relevant)
local opt = vim.opt


-- Set highlight on search
o.hlsearch        = true

-- Show line numbers
wo.number         = false

-- Sync clipboard between OS and Neovim.
-- sync everything to primary clip (middle click)
-- vim.o.clipboard = 'unnamed'
-- sync everything to secondary clip (ctrl-shift-v)
-- vim.o.clipboard = 'unnamedplus'

-- Enable break indent
o.breakindent     = true

-- Save undo history
o.undofile        = true

o.ignorecase      = false
o.smartcase       = false

-- Keep signcolumn on by default
wo.signcolumn     = 'yes'

-- Decrease update time
o.updatetime      = 250
-- vim.o.timeoutlen = 300
o.timeoutlen      = 250

o.completeopt     = 'menuone,noselect'
-- This is what I had before, is menuone,noselect better?
-- o.completeopt     = 'menu'

-- always show statusline
opt.laststatus    = 2

-- emit true, 24-bit color to the terminal
opt.termguicolors = true
opt.pumblend      = 25
opt.winblend      = 25

-- shared data
opt.shada         = "!,'100,<50,s10,h"

opt.mousehide     = true               -- hide the mouse when typing text
opt.mouse         = "a"                -- use your mouse in a terminal
opt.cmdheight     = 1                  -- make command line one line high (default)
opt.backspace     = "indent,eol,start" -- backspace over autoindent, join lines, start of insert
opt.tabstop       = 4                  -- spaces that <Tab> in file counts when displaying
opt.shiftwidth    = 4                  -- number spaces to shift things
opt.textwidth     = 78                 -- limit text width to 78
opt.autoindent    = true               -- uses indent from the previous line
opt.softtabstop   = 4                  -- soft tab stop
opt.expandtab     = true               -- use spaces instead of tab (Ctrl-V<Tab> for real tab)
opt.ruler         = true               -- shows line and col number
opt.formatoptions = l                  -- autoformating (l=long lines not broken on insert)
opt.guicursor     = "a:blinkon0"       -- disable cursor blink
opt.autoread      = true               -- reload files changed outside vim
opt.history       = 2000               -- size of command history
opt.fileformats   = "unix,dos,mac"     -- eol formats to try first

opt.list          = true
opt.listchars     = { tab = "»·" } -- Indicate tabs (so 2 tabs: »···»···)
opt.wrap          = true           -- Use word wrap by default
opt.title         = true           -- Window shows filename being edited
opt.foldlevel     = 20             -- Start with a deep foldlevel
