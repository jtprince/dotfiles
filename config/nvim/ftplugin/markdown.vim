
"clipboard (<ctrl>-c) as link name, primary (X-clipboard) as url address
map <leader>mp <Esc>i[<Esc>"*pa](<Esc>"+pa)

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
