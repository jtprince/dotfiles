" Vim color file
" John T. Prince <jtprince@gmail.com>
" A light scheme for a 256 color terminal

set background=light
hi clear
if exists("syntax_on")
    syntax reset
endif
colorscheme default
let g:colors_name = "jtplight"

" See https://jonasjacek.github.io/colors/
" By avoiding 0-15 or names, we avoid system colors
" So, this will be constant regardless of any system colors
hi Normal       ctermbg=230     ctermfg=16  " Cornsilk1 and Grey0
hi Comment                      ctermfg=69 " CornflowerBlue
hi Constant                     ctermfg=21  " Blue1
hi Special      cterm=bold      ctermfg=124 " Red3
hi Identifier   cterm=bold      ctermfg=22  " DarkGreen

hi Statement    cterm=bold      ctermfg=18  " DarkBlue
hi PreProc                      ctermfg=16  " Grey0
hi Type         cterm=bold      ctermfg=201
hi Function     cterm=bold      ctermfg=88  " DarkRed
hi Repeat                       ctermfg=88  " DarkRed
hi Operator     cterm=bold      ctermfg=88  " DarkRed
hi Ignore                       ctermfg=16  " Grey0
hi Error        cterm=reverse   ctermbg=196 ctermfg=231 " Red1 on Grey100
hi Todo         cterm=standout  ctermbg=226 ctermfg=21  " Yellow1 on Blue1
