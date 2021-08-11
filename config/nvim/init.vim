" John T. Prince

" PACKAGE MGT ================================================================
"   STEPS:
"   yay -S neovim-plug-git
"   yay -S nodejs   # for coc
"   mkdir ~/.local/share/vimplugins
"
"   After altering, run :PlugInstall to update
"
call plug#begin('~/.local/share/vimplugins')
" automatically sets:
" filetype plugin indent on
" syntax enable
"
" Must use single quotes

" pacaur -S universal-ctags-git
Plug 'ludovicchabant/vim-gutentags'
let g:gutentags_ctags_tagfile='.tags'
" CTRL+] to navigate to tag under cursor
" CTRL+t climb back up the tree
" :tag function_name
" :help tags
" Plug 'ycm-core/YouCompleteMe'

Plug 'powerline/powerline'

Plug 'scrooloose/nerdcommenter'
" Align all comments to the left margin
let g:NERDDefaultAlign = 'left'
let g:NERDCommentEmptyLines = 1
let g:NERDTrimTrailingWhitespace = 1

Plug 'ntpeters/vim-better-whitespace'
" :StripWhitespace (also :ToggleWhitespace)

"Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
"let g:deoplete#enable_at_startup = 1

Plug 'nvie/vim-flake8'
" <F7> runs flake8

Plug 'vim-ruby/vim-ruby'
Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries' }

Plug 'gisraptor/vim-lilypond-integrator'
Plug 'vim-scripts/AnsiEsc.vim'
Plug 'christoomey/vim-titlecase'

" crs coerce to snake_case; crc coerce to camelCase
Plug 'tpope/vim-abolish'

Plug 'gelguy/wilder.nvim', { 'do': ':UpdateRemotePlugins' }


" Distraction free editing (:Goyo to toggle)
Plug 'junegunn/goyo.vim'
let g:goyo_width = '90%'
let g:goyo_height = '90%'

" Telescope necessary plugins
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

" Treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" markdown
" May also consider gabrielelana's https://github.com/gabrielelana/vim-markdown
" In the past, have used 'tpope/vim-markdown'
"
" And have used vim-markdown-toc:
"" Plug 'mzlogin/vim-markdown-toc'
" let g:vmt_auto_update_on_save = 1
" let g:vmt_dont_insert_fence = 0

" For now, using plasticboy's markdown plugin

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

" let g:vim_markdown_conceal = 1

" Glow [path-to-md-file] (q to close)
Plug 'npxbr/glow.nvim', {'do': ':GlowInstall', 'branch': 'main'}

Plug 'axlebedev/footprints'
let g:footprintsColor = '#c0c0c0'
" let g:footprintsTermColor = '143'
let g:footprintsEasingFunction = 'linear'
let g:footprintsHistoryDepth = 20
let g:footprintsExcludeFiletypes = ['magit', 'nerdtree', 'diff']
" disable until I can figure out color scheme
let g:footprintsEnabledByDefault = 0
let g:footprintsOnCurrentLine = 0

" Note using ctrlp, instead trying out FZF
" Plug 'kien/ctrlp.vim'
" I USE FZF, installed by yay -S fzf, which loads the file already
" open fzf in popup window:
let g:fzf_layout = { 'window': { 'width': 0.95, 'height': 0.8 } }

" Also use a set of customization commands for fzf
Plug 'junegunn/fzf.vim'

" search fzf in proximity to current buffer
" yay -S proximity-sort ripgrep
" https://balatero.com/writings/vim/fzf-ripgrep-proximity-sort/
"
function! g:FzfFilesSource()
  let l:base = fnamemodify(expand('%'), ':h:.:S')
  let l:proximity_sort_path = '/usr/bin/proximity-sort'

  if base == '.'
    return 'rg --files'
  else
    return printf('rg --files | %s %s', l:proximity_sort_path, expand('%'))
  endif
endfunction

" json with comments
Plug 'kevinoid/vim-jsonc'

Plug 'neoclide/coc.nvim', {'branch': 'release'}
let g:coc_config_home = $XDG_CONFIG_HOME."/nvim/coc-settings.json"

" coc needs to be rooted for things like pylint to work properly!
autocmd FileType python let b:coc_root_patterns = ['.git', '.env', 'venv', '.venv', 'setup.cfg', 'setup.py', 'pyproject.toml', 'pyrightconfig.json']

Plug 'fidian/hexmode'
let g:hexmode_patterns = '*.bin,*.exe,*.dat,*.o'

" Enables :rename <new_filename>
Plug 'danro/rename.vim'

"" python mode is the only reliable way to get at rope functionality
"Plug 'python-mode/python-mode', { 'branch': 'develop' }
"let g:python3_host_prog = '/usr/bin/python3'

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

" FZF (ctrl-p alternative) bindings
noremap <C-f> :FZF<CR>

noremap <C-n> :bnext<CR>
noremap <C-p> :bprevious<CR>

" Ctrl-P config
" let g:ctrlp_custom_ignore = {
"     \ 'dir':  '\.git$\|\.hg$\|\.svn$\|\.yardoc\|public\/images\|public\/system\|tmp$\|node_modules$',
"     \ 'file': '\.pyc\.exe$\|\.so$\|\.dat$'
" \ }
" let g:ctrlp_follow_symlinks = 1

" even following branch: stable it's broken like this: https://github.com/psf/black/issues/1304
" Plug 'psf/black', { 'branch': 'stable' }
" so peg to specific version for now :/
Plug 'psf/black', { 'commit': 'ce14fa8b497bae2b50ec48b3bd7022573a59cdb1' }

let g:black_linelength=80

" Provides autoimport, but requires python2 :/
" Plug 'dbsr/vimpy'
" let g:vimpy_prompt_resolve = 1
" let g:vimpy_remove_unused = 1
" :VimpyCheckLine
"
" consider rope for auto import

Plug 'mustache/vim-mustache-handlebars'


call plug#end()

" always show statusline
:set laststatus=2

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
" easier window control generally
noremap <leader>w <C-w>

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
  autocmd BufRead *.mkd *.md set ai formatoptions+=l lbr formatoptions=tcroqn2 comments=n:>
augroup END
" yaml
autocmd BufRead *.yml set ts=2 sw=2 sts=2
autocmd BufRead *.yaml set ts=2 sw=2 sts=2
" latex
autocmd BufRead *.tex set formatoptions+=l lbr
" text and log
autocmd BufRead *.txt set formatoptions+=l lbr
autocmd BufRead *.log set formatoptions+=l lbr

" make
autocmd FileType make setlocal noexpandtab   " turn off et for makefiles
autocmd Filetype html setlocal ts=2 sw=2 sts=2 expandtab
autocmd Filetype ruby setlocal ts=2 sw=2 sts=2 expandtab
autocmd Filetype javascript setlocal ts=4 sw=4 sts=4 expandtab
autocmd Filetype tex setlocal foldmethod=syntax
autocmd FileType python let b:coc_root_patterns = ['.git', '.env']

" to get folds going on most filetypes, merely do
" set foldmethod=syntax
" then zc (close) zo (open) etc

" pretty format json:
"%!python -m json.tool

function PrePythonCleanup()
    execute 'Black'
    execute 'CocCommand python.sortImports'
endfunction
autocmd BufWritePost *.py call Flake8()
autocmd BufWritePre *.py call PrePythonCleanup()

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
call wilder#set_option('renderer', wilder#popupmenu_renderer({'highlighter': wilder#basic_highlighter()}))

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

" COLOR CONFIG ===============================================================

colorscheme tortejtp
" colorscheme jtplight
