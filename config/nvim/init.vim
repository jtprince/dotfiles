" John T. Prince

" PACKAGE MGT ================================================================
" setup (bash):
"   curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
"      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
"   mkdir ~/.local/share/vimplugins
call plug#begin('~/.local/share/vimplugins')
" automatically sets:
" filetype plugin indent on
" syntax enable
"
" Must use single quotes

Plug 'ludovicchabant/vim-gutentags'
let g:gutentags_ctags_tagfile='.tags'
" CTRL+] to navigate to tag under cursor
" CTRL+t climb back up the tree
" :tag function_name
" :help tags

Plug 'scrooloose/nerdcommenter'
Plug 'ntpeters/vim-better-whitespace'
" :StripWhitespace (also :ToggleWhitespace)

Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
let g:deoplete#enable_at_startup = 1

Plug 'nvie/vim-flake8'
" <F7> runs flake8

Plug 'vim-ruby/vim-ruby'
Plug 'tpope/vim-markdown'
Plug 'gisraptor/vim-lilypond-integrator'
Plug 'vim-scripts/AnsiEsc.vim'

Plug 'kien/ctrlp.vim'

Plug 'python-mode/python-mode', { 'branch': 'develop' }
let g:pymode_python = 'python3'
" pymode is too aggressive with folding
set nofoldenable
" turn off default pymode options and just set what we want
let g:pymode_options = 0
setlocal complete+=t
setlocal formatoptions-=t
"if v:version > 702 && !&relativenumber
"    setlocal number
"endif
setlocal nowrap
setlocal textwidth=79
setlocal commentstring=#%s
setlocal define=^\s*\\(def\\\\|class\\)

let g:pymode_options_max_line_length=120

" Ctrl-P config
let g:ctrlp_custom_ignore = {
    \ 'dir':  '\.git$\|\.hg$\|\.svn$\|\.yardoc\|public\/images\|public\/system\|tmp$\|node_modules$',
    \ 'file': '\.pyc\.exe$\|\.so$\|\.dat$'
\ }
let g:ctrlp_follow_symlinks = 1

call plug#end()

" must be in this order for plugins

" META LEVEL =================================================================

" hail the all powerful leader key!
let g:mapleader = ','

" use semicolon for all colon commands
:noremap ; :

" STATE ======================================================================

set shada=!,'100,<50,s10,h

" GENERAL CONFIG =============================================================

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
set hidden                      " buffers can exist in bkg w/o window
set history=1000                " size of command history
set fileformats=unix,dos,mac    " eol formats to try first

set guioptions-=m               " remove the menu bar
set guioptions-=T               " remove the gui toolbar
set guioptions-=r               " remove the right scrollbar

set list listchars=tab:»·       " Indicate tabs (so 2 tabs: »···»···)

" NOTE: Holding down SHIFT enables before mousing over a selection enables
" a terminal to grab the selection for pasting

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
" easier window control generally
noremap <leader>w <C-w>

" easier window navigation by holding down Ctrl
map <C-J> <C-W>j
map <C-K> <C-W>k
map <C-H> <C-W>h
map <C-L> <C-W>l

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

" COLOR CONFIG ===============================================================

colorscheme tortejtp
" colorscheme jtplight
