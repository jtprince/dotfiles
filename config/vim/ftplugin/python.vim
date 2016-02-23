map <leader>m <Esc>o""" [method name documents expected behavior] """<Esc>0
" imap <leader>m <Esc>o""" [method name documents expected behavior] """<Esc>0

map <leader>s <Esc>o""" [self documenting] """<Esc>0
" imap <leader>s <Esc>o""" [self documenting] """<Esc>0

" :Isort will sort all your imports according to PEP8 and GSG
command! -range=% Isort :<line1>,<line2>! isort -

" :Isortdoba will sort all your imports according to PEP8 and GSG
command! -range=% Isortdoba :<line1>,<line2>! isort-doba -

" opens a print statement based on the given word
" print('DBG: %r" % <var>)
" line *below* the word
map <leader>o <Esc>byeoprint("DBG: <Esc>pa: %r" % <Esc>p<Esc>a)<Esc>0w
" line *above* the word
map <leader>O <Esc>byeOprint("DBG: <Esc>pa: %r" % <Esc>p<Esc>a)<Esc>0w


" line *below* the word (with vars(<var>))
map <leader>p <Esc>byeoprint("DBG: <Esc>pa: %r" % <Esc>p<Esc>a, vars(<Esc>p<Esc>a))<Esc>0w
" line *below* the word (with vars(<var>))
map <leader>P <Esc>byeOprint("DBG: <Esc>pa: %r" % <Esc>p<Esc>a, vars(<Esc>p<Esc>a))<Esc>0w

" uses john's mapping for movement
" turn a single line comment into a multi-line comment.
map <leader>C <Esc>0wea<Enter><Esc>$bba<Enter><Enter><Esc>d0k$o<Enter><Esc>kkd

" turn a single multi-line comment into a single line comment (geared around 4
" lines of comment).
map <leader>c <Esc>0JJJJ)b

map <leader>p <Esc>$a  # pylint: disable=
