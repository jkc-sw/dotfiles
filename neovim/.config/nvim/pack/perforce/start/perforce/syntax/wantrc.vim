
" Reference: https://learnvimscriptthehardway.stevelosh.com/chapters/44.html
" Reference: https://vim.fandom.com/wiki/Creating_your_own_syntax_files
if exists("b:current_syntax")
    finish
endif

" Comment type
syntax match wantrcComment "\v^[^0-9a-zA-Z].*$" contains=wantrcCommentDoxy
highlight link wantrcComment Comment

" Comment type - doxygen tags
syntax match wantrcCommentDoxy "\v[^0-9a-zA-Z]\zs(\@|\\)[a-zA-Z]+"
highlight link wantrcCommentDoxy Constant

" Entry
syntax match wantrcEntry "\v^[0-9a-zA-Z][^=]+\=.*$" contains=wantrcKey,wantrcAssignmentOp,wantrcValue

" Key
syntax match wantrcKey "\v^[0-9a-zA-Z][^=]+" contained nextgroup=wantrcAssignmentOp
highlight link wantrcKey None

" Assignment operator
syntax match wantrcAssignmentOp "\v\=" contained nextgroup=wantrcValue
highlight link wantrcAssignmentOp Operator

" Value
syntax match wantrcValue "\v[^=]*$" contained
highlight link wantrcValue String

let b:current_syntax = "wantrc"

" vim:et ts=4 sts=4 sw=4
