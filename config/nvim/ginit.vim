colorscheme jtplightgui
" nvim-qt style
" Guifont DejaVu Sans Mono:h11

" specific to neovim-gtk
call rpcnotify(1, 'Gui', 'Font', 'DejaVu Sans Mono 10')

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
