" Indentation code from Eric Mc Sween <em@tomcom.de> and David Bustos <bustos@caltech.edu>
" Only load this indent file when no other was loaded.

function! InsertCommandlineProgram()
    " the -1read inserts without the extra newline at the top
    .-1read ~/.config/nvim/ftplugin/python-fragments/commandline_program.py
endfunction

function! InsertSetupMethod()
    " the -1read inserts without the extra newline
    .-1read ~/.config/nvim/ftplugin/python-fragments/setup_method.py
endfunction

iab improt import
iab imrpot import
iab imrpt import
iab imprt import
iab iport import
iab impot import
iab impowt import
iab imropt import
iab ipt import
iab ipt import
iab ii import
iab prtin print

noremap <leader>o <Esc>:Isort<CR>

" pylint disable using the X11 buffer (highlight 'E1101-no-member' and it will
" inject the trailer:  pylint: disable=no-member
" noremap <leader>a <Esc>$a  # pylint: disable=<Esc>"*p<Esc>?=<Enter>wkwx<Esc>:noh<Enter>$

" The movement down one line (with left hand navigation) assumes that an import line was added
" noremap <leader>i <Esc>mw:PymodeRopeAutoImport<Enter>1<Enter><Esc>:Isort<Enter>`wf

noremap <leader>b <Esc>:Black<CR>

" insert breakpoint above the current line and position cursor at start of
" breakpoint
noremap <leader>B Obreakpoint()<Esc>0w

" hop to next/prev class or def
nnoremap ]] /^\s*class\|^\s*def<CR>
nnoremap [[ ?^\s*class\|^\s*def<CR>


