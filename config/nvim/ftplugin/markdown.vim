
"clipboard (<ctrl>-c) as link name, primary (X-clipboard) as url address

" if the link has extra lines in it
map <leader>ml <Esc>i[<Esc>"*pa<Esc>0i<BS><Esc>$a](<Esc>"+pa)
" if the link has no extra lines in it
map <leader>mp <Esc>i[<Esc>"*pa](<Esc>"+pa)

map <leader>mq i`<Esc>ea`<Esc>

" means that 'my-link' will be interpreted as single keyword 'my-link' instead
" of two words
setlocal iskeyword+=-


function! InsertKnowledgeRepoHeader()
    " insert the snippet, but remove that pesky extra line at the top
    .-1read ~/.config/nvim/ftplugin/markdown-fragments/knowledge_repo_header.md
    " insert the date (swap out CREATED_AT)
    let @d=strftime('%Y-%m-%d')
    %s/CREATED_AT/\=@d/
    " move back to beginning of file to edit the title
    normal! 1G
    " move down (uses normal keys, not my left-hand navigation)
    normal! j
    " move to end of the line, ready to edit the title
    normal! $
endfunction


function! MarkdownToHTMLAndOpenInFirefox()
    silent !markdown-to-html %
    silent !firefox "%:r.html" &
endfunction

function! MarkdownToPDFAndOpenInEvince()
    silent !markdown-to-pdf %
    silent !evince "%:r.pdf" &
endfunction

map <leader>mh <Esc>:call MarkdownToHTMLAndOpenInFirefox()<CR>
map <leader>mp <Esc>:call MarkdownToPDFAndOpenInEvince()<CR>
