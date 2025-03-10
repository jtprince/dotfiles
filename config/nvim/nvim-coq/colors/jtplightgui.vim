" Vim color file
" Maintainer:	John T. Prince <jtprince@gmail.com>
" Last Change:	2012-06-19
" $Revision: 1.0 $

set background=light
hi clear
if exists("syntax_on")
    syntax reset
endif
colorscheme default
let g:colors_name = "jtplight"

hi Normal                                           guifg=black guibg=LightYellow
hi Comment      term=bold       ctermfg=DarkBlue	guifg=RoyalBlue
hi Constant     term=underline  ctermfg=blue    guifg=blue
hi Special      term=bold       ctermfg=DarkRed	guifg=DarkRed
hi Identifier   term=underline  cterm=bold          ctermfg=DarkGreen	guifg=DarkGreen
hi Statement    term=bold       cterm=bold  ctermfg=LightBlue gui=bold        guifg=DarkBlue
hi PreProc      term=underline  ctermfg=black	guifg=black
hi Type         term=underline  ctermfg=Magenta	guifg=Magenta gui=bold
hi Function     term=bold       ctermfg=Red guifg=DarkRed
hi Repeat       term=underline  ctermfg=Red       guifg=DarkRed
hi Operator                     ctermfg=Red	guifg=DarkRed
hi Ignore                       ctermfg=black   guifg=bg
hi Error        term=reverse    ctermbg=Red         ctermfg=White guibg=Red   guifg=White
hi Todo         term=standout   ctermbg=Yellow      ctermfg=Blue	guifg=Blue  guibg=Yellow
