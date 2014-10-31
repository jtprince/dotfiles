map <leader>m <Esc>o""" [method name documents expected behavior] """<Esc>0
imap <leader>m <Esc>o""" [method name documents expected behavior] """<Esc>0

map <leader>s <Esc>o""" [self documenting] """<Esc>0
imap <leader>s <Esc>o""" [self documenting] """<Esc>0

" :Isort will sort all your imports according to PEP8 and GSG
command! -range=% Isort :<line1>,<line2>! isort --force_single_line_imports --lines 160 -
