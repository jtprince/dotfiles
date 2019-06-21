" Indentation code from Eric Mc Sween <em@tomcom.de> and David Bustos <bustos@caltech.edu>
" Only load this indent file when no other was loaded.

" :Isort will sort all your imports according to PEP8 and GSG
command! -range=% Isort :<line1>,<line2>! isort -

map <leader>o <Esc>mw:Isort<Enter>`w

" uses john's mapping for movement
" turn a single line comment into a multi-line comment.
map <leader>C <Esc>0wea<Enter><Esc>$bba<Enter><Enter><Esc>d0k$o<Enter><Esc>kkd

" turn a single multi-line comment into a single line comment (geared around 4
" lines of comment).
map <leader>c <Esc>0JJJJ)b

" pylint disable using the X11 buffer (highlight 'E1101-no-member' and it will
" inject the trailer:  pylint: disable=no-member
map <leader>a <Esc>$a  # pylint: disable=<Esc>"*p<Esc>?=<Enter>wkwx<Esc>:noh<Enter>$

" The movement down one line (with left hand navigation) assumes that an import line was added
map <leader>i <Esc>mw:PymodeRopeAutoImport<Enter>1<Enter><Esc>:ISortdoba<Enter>`wf

map <leader>= <Esc>:Black<Enter>
