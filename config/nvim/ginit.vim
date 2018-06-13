colorscheme jtplightgui
" nvim-qt
" Guifont DejaVu Sans Mono:h11

" yanks the mouse selection to X11 clipboard after releasing the button
" the s moves one character left
" vmap <LeftRelease> "*y
noremap <leader>y "*y
noremap <leader>Y "+y

if exists('g:GtkGuiLoaded')
    let g:GuiInternalClipboard = 1
    call rpcnotify(1, 'Gui', 'Font', 'DejaVu Sans Mono 10')
endif
