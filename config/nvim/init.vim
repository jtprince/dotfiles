" John T. Prince

" ============================================================================
" PACKAGE MGT
" ============================================================================
"   STEPS:
"   yay -S neovim-plug-git
"   mkdir ~/.local/share/vimplugins
"
"   After altering, run :PlugInstall to update
"   (source $MYVIMRC to refresh)
"
call plug#begin('~/.local/share/vimplugins')
" automatically sets:
" filetype plugin indent on
" syntax enable
"
" Must use single quotes

" c-tags ---------------------------------------------------------------------
" pacaur -S universal-ctags-git
Plug 'ludovicchabant/vim-gutentags'
let g:gutentags_ctags_tagfile='.tags'
" CTRL+] to navigate to tag under cursor
" CTRL+t climb back up the tree
" :tag function_name
" :help tags

" comments -------------------------------------------------------------------
Plug 'scrooloose/nerdcommenter'
" Align all comments to the left margin
let g:NERDDefaultAlign = 'left'
let g:NERDCommentEmptyLines = 1
let g:NERDTrimTrailingWhitespace = 1

" file explorer
Plug 'ms-jpq/chadtree', {'branch': 'chad', 'do': 'python3 -m chadtree deps'}

" testing --------------------------------------------------------------------
Plug 'vim-test/vim-test'

" colorscheme ----------------------------------------------------------------
" vim-misc required for vim-colorscheme-switcher
Plug 'xolox/vim-misc'
Plug 'xolox/vim-colorscheme-switcher'
Plug 'jtprince/vim-colorschemes'
Plug 'bluz71/vim-moonfly-colors'
Plug 'shaunsingh/moonlight.nvim'
Plug 'Neur1n/neucs.vim'

" git -------------------------------------------------------------------------
Plug 'tpope/vim-fugitive'

" plenary required by gitlinker.nvim (sourced above with telescope)
Plug 'ruifm/gitlinker.nvim'
" gy (yank current file, current version w/ lines if visual mode)
" gY yank repo url to clipboard
" gB open repo url in your default browser

" markdown ------------------------------------------------------------------
" Tabular is used to format markdown tables
Plug 'godlygeek/tabular'
" JSON front matter highlight plugin
Plug 'elzr/vim-json'
" https://github.com/plasticboy/vim-markdown
Plug 'plasticboy/vim-markdown'
let g:vim_markdown_folding_disabled = 0
let g:vim_markdown_conceal = 0
" control conceallevel with
"     :set conceallevel=0  # no conceal
"     :set conceallevel=1  # some conceal
"     :set conceallevel=2  # lots of conceal

let g:vim_markdown_frontmatter = 1
let g:vim_markdown_toml_frontmatter = 1  " for TOML format
let g:vim_markdown_json_frontmatter = 1  " for JSON format
" let's you jump to #anchor or file#anchor in file
let g:vim_markdown_follow_anchor = 1
let g:vim_markdown_strikethrough = 1

let g:vim_markdown_auto_insert_bullets = 0
let g:vim_markdown_new_list_item_indent = 0

" Note: this is not necessary for github because it will auto-generate toc
" markdown table of contents
Plug 'mzlogin/vim-markdown-toc'
" :GenTocGFM (for gitubflavored toc)
" :GenTocRedcarpet (for redcarpet toc)
"
Plug 'masukomi/vim-markdown-folding'



" Glow [path-to-md-file] (q to close)
Plug 'npxbr/glow.nvim', {'do': ':GlowInstall', 'branch': 'main'}

" lsp and autocomplete ------------------------------------------------------
" Required for LSP support for coq:
Plug 'neovim/nvim-lspconfig'

Plug 'ms-jpq/coq_nvim', {'branch': 'coq'}
" 9000+ Snippets
Plug 'ms-jpq/coq.artifacts', {'branch': 'artifacts'}

" Show function signatures
" [cannot get this to work yet, need to play with config more]
" Plug 'ray-x/lsp_signature.nvim'

" Telescope -----------------------------------------------------------------
" plenary and popup are requirements
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-telescope/telescope.nvim'

" python  -------------------------------------------------------------------

" Set the python that nvim will use globally
" This will need to change if you need/want to use a specific virtualenv with
" nvim.
" let g:python3_host_prog = '/usr/bin/python3'

Plug 'nvie/vim-flake8'
" <F7> runs flake8

Plug 'psf/black', { 'branch': 'stable' }
let g:black_linelength=79

Plug 'stsewd/isort.nvim', { 'do': ':UpdateRemotePlugins' }
let g:isort_command = 'isort'

"" python mode is the only reliable way to get at rope functionality
"Plug 'python-mode/python-mode', { 'branch': 'develop' }

"let g:pymode_python = 'python3'
"" turn off default pymode options and just set what we want
"let g:pymode_options = 0
"" setlocal complete+=t
"" setlocal formatoptions-=t
"" setlocal commentstring=#%s
"" setlocal define=^\s*\\(def\\\\|class\\)

"" invoke as: nvim -c 'let g:pymode_rope=0' to turn off at outset
"let g:pymode_rope = 1
"let g:pymode_rope_autoimport = 1
"let g:pymode_options_max_line_length=120
"let g:pymode_rope_complete_on_dot = 0
"let g:pymode_rope_completion = 0
"" pymode is really a collection of packages, see info on each:
""     https://github.com/python-mode/python-mode/wiki
"" The command: <Ctrl-c> f
""     will find all occurences of the python name under the cursor

" consider rope for auto import

" misc ----------------------------------------------------------------------

" visual select (Ctrl-V) then Ctrl-A to auto-increment
Plug 'triglav/vim-visual-increment'
set nrformats=bin,hex,alpha

Plug 'mechatroner/rainbow_csv'

Plug 'mustache/vim-mustache-handlebars'

Plug 'ntpeters/vim-better-whitespace'
" :StripWhitespace (also :ToggleWhitespace)

Plug 'vim-ruby/vim-ruby'

Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries' }

Plug 'gisraptor/vim-lilypond-integrator'
Plug 'vim-scripts/AnsiEsc.vim'
Plug 'christoomey/vim-titlecase'

" crs coerce to snake_case; crc coerce to camelCase
Plug 'tpope/vim-abolish'

Plug 'gelguy/wilder.nvim', { 'do': ':UpdateRemotePlugins' }

" For communication with qtconsole
Plug 'jupyter-vim/jupyter-vim'
" Edit jupyter files directly (requires pip install jupytext)
Plug 'goerz/jupytext.vim'
let g:jupytext_enable = 1
let g:jupytext_print_debug_msgs = 1

" Distraction free editing (:Goyo to toggle)
Plug 'junegunn/goyo.vim'
let g:goyo_width = '90%'
let g:goyo_height = '90%'

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

Plug 'fidian/hexmode'
let g:hexmode_patterns = '*.bin,*.exe,*.dat,*.o'

" Enables :rename <new_filename>
Plug 'danro/rename.vim'

" json with comments
Plug 'kevinoid/vim-jsonc'

Plug 'fladson/vim-kitty'

" not using right now -----------------------------------------------------

" Plug 'axlebedev/footprints'
" let g:footprintsColor = '#c0c0c0'
" " let g:footprintsTermColor = '143'
" let g:footprintsEasingFunction = 'linear'
" let g:footprintsHistoryDepth = 20
" let g:footprintsExcludeFiletypes = ['magit', 'nerdtree', 'diff']
" " disable until I can figure out color scheme
" let g:footprintsEnabledByDefault = 0
" let g:footprintsOnCurrentLine = 0

" Am I really using this?
" Plug 'powerline/powerline'

call plug#end()

" ============================================================================
" GLOBAL CONFIG
" ============================================================================
" always show statusline
set laststatus=2

" emit true, 24-bit color to the terminal
set termguicolors
set pumblend=25
set winblend=25
" haven't been able to get guicursor to work on alacritty
" set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20

" Rope autocomplete
" pip install --user rope ropevim
" must be in this order for plugins

" META LEVEL =================================================================

" !leader key!
let g:mapleader = ','

" use semicolon for all colon commands
:noremap ; :

" STATE ======================================================================

set shada=!,'100,<50,s10,h

" GENERAL CONFIG =============================================================

" required by vim-markdown-folding
set nocompatible
if has("autocmd")
    filetype plugin indent on
endif

set mousehide                   " hide the mouse when typing text
set mouse=a                     " use your mouse in a terminal
set cmdheight=1                 " make command line one line high (default)
set backspace=indent,eol,start  " backspace over autoindent, join lines, start of insert
set tabstop=4                   " spaces that <Tab> in file counts when displaying
set shiftwidth=4                " number spaces to shift things
set textwidth=78                " limit text width to 78
set autoindent                  " uses indent from the previous line
set softtabstop=4               " soft tab stop
set expandtab                   " use spaces instead of tab (Ctrl-V<Tab> for real tab)
set ruler                       " shows line and col number
set formatoptions=l             " autoformating (l=long lines not broken on insert)
set printoptions=paper:letter   " use letter instead of A4 by default
set guicursor=a:blinkon0        " disable cursor blink
set autoread                    " reload files changed outside vim
" set hidden                      " buffers can exist in bkg w/o window
set history=1000                " size of command history
set fileformats=unix,dos,mac    " eol formats to try first

set guioptions-=m               " remove the menu bar
set guioptions-=T               " remove the gui toolbar
set guioptions-=r               " remove the right scrollbar

set list listchars=tab:»·       " Indicate tabs (so 2 tabs: »···»···)
set wrap                        " Use word wrap by default
set title                       " Window shows filename being edited
set completeopt=menu            " Only show the popup menu, not the preview buffer
set foldlevel=20                " Start with a deep foldlevel
" virtualedit=all breaks some expected functionality, so best to use on demand
" set virtualedit=all             " let's cursor move around freely, great for md tables

" NOTE: Holding down SHIFT enables before mousing over a selection enables
" a terminal to grab the selection for pasting

" BUFFERS ====================================================================

noremap <C-n> :bnext<CR>
noremap <C-p> :bprevious<CR>

" SEARCH =====================================================================

set hlsearch              " Highlight search pattern matches
nmap <silent> <leader>/ :set invhlsearch<CR>

" DEBUG ======================================================================
" <leader> p is reserved for a debugging statement in different languages

" FIX TYPOS ==================================================================

iab pritn print
iab pirnt print
iab serach search

" WORD WRAP ===================================================================
":call WordWrap()
function WordWrap()
    set formatoptions+=l
    set lbr
endfunction

":call NoWordWrap()
function NoWordWrap()
    set formatoptions-=l
    set nolbr
endfunction

" WINDOW NAV =================================================================
" easier window navigation by holding down Ctrl
map <C-J> <C-W>j
map <C-K> <C-W>k
map <C-H> <C-W>h
map <C-L> <C-W>l

" SWAP FILES =================================================================

set nobackup    " no ~ files
set noswapfile  " no .file.swp files
set nowb        " no automatic write backup

" TABS ======================================================================
" vim -p <file> <file> ... # opens pages in tabs
" close the current tab
"
" this conflicts with all the movement... need better mapping
" nnoremap <C-w> :tabclose<CR>
nnoremap <C-S-tab> :tabprevious<CR>
nnoremap <C-tab>   :tabnext<CR>
inoremap <C-S-tab> <Esc>:tabprevious<CR>i
inoremap <C-tab>   <Esc>:tabnext<CR>i

" PERSISTENT UNDO ============================================================
" Keep undo history across sessions, by storing in file.

silent !mkdir ~/tmp/.vim-backups > /dev/null 2>&1
set undodir=~/tmp/.vim-backups
set undofile

" avoid ~/.config/nvim/.netrwhist
let g:netrw_home=$XDG_CACHE_HOME.'/nvim'

" SIMPLE LANGUAGE EXTENSIONS =================================================
" markdown
augroup mkd
  autocmd BufRead *.mkd *.md set ai formatoptions+=l lbr formatoptions=tcroqn2 comments=n:> foldexpr=NestedMarkdownFolds()
augroup END
autocmd FileType markdown setlocal spell

" yaml
autocmd BufRead *.yml set ts=2 sw=2 sts=2
autocmd BufRead *.yaml set ts=2 sw=2 sts=2
" latex
autocmd BufRead *.tex set formatoptions+=l lbr
" text and log
autocmd BufRead *.txt set formatoptions+=l lbr
autocmd BufRead *.log set formatoptions+=l lbr

" make
autocmd FileType make setlocal noexpandtab
autocmd Filetype html setlocal ts=2 sw=2 sts=2 expandtab
autocmd Filetype ruby setlocal ts=2 sw=2 sts=2 expandtab
autocmd Filetype javascript setlocal ts=4 sw=4 sts=4 expandtab
autocmd Filetype tex setlocal foldmethod=syntax

" to get folds going on most filetypes, merely do
" set foldmethod=syntax
" then zc (close) zo (open) etc

" pretty format json:
"%!python -m json.tool

" This is not working right now :/, need to debug more
function PrePythonCleanup()
    execute 'Isort'
    execute 'Black'
    sleep 50m
endfunction
autocmd BufWritePre *.py call PrePythonCleanup()
autocmd BufWritePost *.py call Flake8()

" SIMPLE TRANSFORMATIONS =================================================
" pretty print the json
noremap <leader>j <Esc>:%!python -m json.tool<Enter>

" LEFT-HANDED NAVIGATION =====================================================
"  (right hand gets tired)
" s (go left) g (go right) d (go down) f (go up)
" h = s  k = d  j = g
noremap s h
noremap g l
noremap d k
noremap f j

noremap h g
noremap l s
noremap k d
noremap j f

noremap hh gg

noremap F <PAGEDOWN>M
noremap D <PAGEUP>M

" =======================================================================
" X11 copy/paste buffers
" =======================================================================

" yanks the mouse selection to X11 clipboard after releasing the button
" the s moves one character left
" vmap <LeftRelease> "*y
noremap <leader>y "*y
noremap <leader>Y "+y

" doesn't work
" noremap <leader><C-y> "*c
" ,<Ctrl+Shift+y>
noremap <leader><C-Y> "+c
" noremap <leader><p> "*p
" noremap <leader><P> "+p
"
" =======================================================================
" Telescope config
" =======================================================================
nnoremap <leader>fs <cmd>Telescope grep_string<cr>
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" =======================================================================
" Glow config
" =======================================================================
nnoremap <leader>mg <cmd>Glow<cr>

" =======================================================================
" Wilder config
" =======================================================================
"
" Until wilder is installed with PlugInstall, cmdline suggestions will be broken
call wilder#enable_cmdline_enter()
set wildcharm=<Tab>
cmap <expr> <Tab> wilder#in_context() ? wilder#next() : "\<Tab>"
cmap <expr> <S-Tab> wilder#in_context() ? wilder#previous() : "\<S-Tab>"

" only / and ? are enabled by default
call wilder#set_option('modes', ['/', '?', ':'])
call wilder#set_option('renderer', wilder#popupmenu_renderer({'winblend': 17, 'highlighter': wilder#basic_highlighter()}))

" =======================================================================
" Treesitter config
" =======================================================================
lua <<EOF
require'nvim-treesitter.configs'.setup {
  -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  ensure_installed = "maintained",
  -- ignore_install = { "javascript" }, -- List of parsers to ignore installing
  highlight = {
    enable = true,              -- false will disable the whole extension
    -- disable = { "c", "rust" },  -- list of language that will be disabled
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = true,
  },
}
EOF

" =======================================================================
" COQ config
" =======================================================================
" COQhelp config
let g:coq_settings = {
    \ 'auto_start': v:true,
    \ 'display.pum.fast_close': v:false,
\ }

" =======================================================================
" LSP config
" =======================================================================
" See here for how to configu lsp_signature:
" https://github.com/ray-x/lsp_signature.nvim#setup--attach-the-plugin
lua << EOF
    local lsp = require "lspconfig"
    local coq = require "coq"

    lsp.pyright.setup(coq.lsp_ensure_capabilities())
EOF

" lua << EOF
"     cfg = {
"         debug = false, -- set to true to enable debug logging
"         log_path = vim.fn.stdpath("cache") .. "/lsp_signature.log", -- log dir when debug is on
"         -- default is  ~/.cache/nvim/lsp_signature.log
"         verbose = false, -- show debug line number
"
"         bind = true, -- This is mandatory, otherwise border config won't get registered.
"                    -- If you want to hook lspsaga or other signature handler, pls set to false
"         doc_lines = 10, -- will show two lines of comment/doc(if there are more than two lines in doc, will be truncated);
"                      -- set to 0 if you DO NOT want any API comments be shown
"                      -- This setting only take effect in insert mode, it does not affect signature help in normal
"                      -- mode, 10 by default
"
"         floating_window = true, -- show hint in a floating window, set to false for virtual text only mode
"
"         floating_window_above_cur_line = true, -- try to place the floating above the current line when possible Note:
"         -- will set to true when fully tested, set to false will use whichever side has more space
"         -- this setting will be helpful if you do not want the PUM and floating win overlap
"
"         floating_window_off_x = 1, -- adjust float windows x position.
"         floating_window_off_y = 1, -- adjust float windows y position.
"
"
"         fix_pos = false,  -- set to true, the floating window will not auto-close until finish all parameters
"         hint_enable = true, -- virtual hint enable
"         hint_prefix = "🐼 ",  -- Panda for parameter
"         hint_scheme = "String",
"         hi_parameter = "LspSignatureActiveParameter", -- how your parameter will be highlight
"         max_height = 12, -- max height of signature floating_window, if content is more than max_height, you can scroll down
"                        -- to view the hiding contents
"         max_width = 80, -- max_width of signature floating_window, line will be wrapped if exceed max_width
"         handler_opts = {
"         border = "rounded"   -- double, rounded, single, shadow, none
"         },
"
"         always_trigger = false, -- sometime show signature on new line or in middle of parameter can be confusing, set it to false for #58
"
"         auto_close_after = nil, -- autoclose signature float win after x sec, disabled if nil.
"         extra_trigger_chars = {}, -- Array of extra characters that will trigger signature completion, e.g., {"(", ","}
"         zindex = 200, -- by default it will be on top of all floating windows, set to <= 50 send it to bottom
"
"         padding = '', -- character to pad on left and right of signature can be ' ', or '|'  etc
"
"         transparency = nil, -- disabled by default, allow floating win transparent value 1~100
"         shadow_blend = 36, -- if you using shadow as border use this set the opacity
"         shadow_guibg = 'Black', -- if you using shadow as border use this set the color e.g. 'Green' or '#121315'
"         timer_interval = 200, -- default timer check interval set to lower value if you want to reduce latency
"         toggle_key = nil -- toggle signature on and off in insert mode,  e.g. toggle_key = '<M-x>'
"     }
"
" require'lsp_signature'.setup(cfg) -- no need to specify bufnr if you don't use toggle_key
" EOF

" =======================================================================
" vim-test
" =======================================================================

let test#python#runner = 'pytest'
let test#strategy = 'neovim'

nnoremap <leader>tn <cmd>TestNearest<cr>
nnoremap <leader>tf <cmd>TestFile<cr>
nnoremap <leader>ts <cmd>TestSuite<cr>
nnoremap <leader>tl <cmd>TestLast<cr>
nnoremap <leader>tg <cmd>TestVisit<cr>

" =======================================================================
" Gitlinker
" =======================================================================

lua <<EOF
    require"gitlinker".setup()
    vim.api.nvim_set_keymap('n', '<leader>gY', '<cmd>lua require"gitlinker".get_repo_url()<cr>', {silent = true})
    vim.api.nvim_set_keymap('n', '<leader>gB', '<cmd>lua require"gitlinker".get_repo_url({action_callback = require"gitlinker.actions".open_in_browser})<cr>', {silent = true})
EOF

" =======================================================================
" File explorer
" =======================================================================
nnoremap <leader>fw <cmd>CHADopen<cr>

" =======================================================================
" ColorSchemeSwitcher
" =======================================================================

nnoremap <leader>sn <cmd>NextColorScheme<cr>
nnoremap <leader>sp <cmd>PrevColorScheme<cr>
nnoremap <leader>sr <cmd>RandomColorScheme<cr>

" COLOR CONFIG ===============================================================

set background=dark
let g:moonlight_terminal_italics=1
colorscheme moonlight
