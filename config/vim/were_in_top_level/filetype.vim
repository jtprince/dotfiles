" markdown filetype file
if exists("did\_load\_filetypes")
finish
endif
augroup markdown
au! BufRead,BufNewFile *.mkd   setfiletype mkd
au! BufRead,BufNewFile *.md   setfiletype mkd
augroup END
autocmd BufNewFile,BufRead *.csv setf csv
