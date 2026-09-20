
if !get(g:, 'jerry_enabled', v:false)
    finish
endif

" Reference: https://learnvimscriptthehardway.stevelosh.com/chapters/44.html
au BufNewFile,BufRead *.inc set filetype=bitbake

" vim:et ts=4 sts=4 sw=4
