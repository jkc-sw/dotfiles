
if !get(g:, 'perforce_enabled', v:false)
    finish
endif

" Reference: https://learnvimscriptthehardway.stevelosh.com/chapters/44.html
au BufNewFile,BufRead *want.*.rc set filetype=wantrc

" vim:et ts=4 sts=4 sw=4
