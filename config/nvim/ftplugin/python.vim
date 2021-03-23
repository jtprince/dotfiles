" Indentation code from Eric Mc Sween <em@tomcom.de> and David Bustos <bustos@caltech.edu>
" Only load this indent file when no other was loaded.

function! SetupMethod()
    r~/.config/nvim/ftplugin/python-fragments/setup_method.py
endfunction


function! SearchUnderKeyword()
  return expand("<cword>")
endfun

" ,s -> search for word across codebase
" noremap <leader>s :execute ':CocSearch ' . SearchUnderKeyword()<CR>
noremap <leader>s :execute ':CocSearch ' . expand("<cword>") <CR>

iab improt import
iab imrpot import
iab imrpt import
iab imprt import
iab iport import

noremap <leader>o <Esc>:CocCommand python.sortImports<CR>

" uses john's mapping for movement
" turn a single line comment into a multi-line comment.
noremap <leader>C <Esc>0wea<Enter><Esc>$bba<Enter><Enter><Esc>d0k$o<Enter><Esc>kkd

" turn a single multi-line comment into a single line comment (geared around 4
" lines of comment).
noremap <leader>c <Esc>0JJJJ)b

" pylint disable using the X11 buffer (highlight 'E1101-no-member' and it will
" inject the trailer:  pylint: disable=no-member
noremap <leader>a <Esc>$a  # pylint: disable=<Esc>"*p<Esc>?=<Enter>wkwx<Esc>:noh<Enter>$

" The movement down one line (with left hand navigation) assumes that an import line was added
noremap <leader>i <Esc>mw:PymodeRopeAutoImport<Enter>1<Enter><Esc>:Isort<Enter>`wf

noremap <leader>b <Esc>:Black<Enter>

" insert breakpoint above the current line and position cursor at start of
" breakpoint
noremap <leader>B Obreakpoint()<Esc>0w

" noremap <leader>s :call SetupMethod()<Esc>fo

" auto imports
" https://github.com/wookayin/vim-autoimport
"
nnoremap <silent> <M-CR>   :ImportSymbol<CR>
inoremap <silent> <M-CR>   <Esc>:ImportSymbol<CR>a


