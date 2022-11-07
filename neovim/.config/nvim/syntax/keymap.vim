
" Reference: https://learnvimscriptthehardway.stevelosh.com/chapters/44.html
" Reference: https://vim.fandom.com/wiki/Creating_your_own_syntax_files
if exists("b:current_syntax")
    finish
endif

" Macro
syntax match Processor "\m^#.*" display
highlight link Processor PreProc

syntax region justString start=/\m"/ end=/\m"/ display
highlight link justString String

" A key entry
syntax match keyMapEntry "\m&[^&]\+\ze\(&\|$\)" contains=keyMapDelimiter,keyMapIgnore,keyMapFunc,keyMapTrans,keyMapKey display

" Delimiter
syntax match keyMapDelimiter "\m&" contained nextgroup=keyMapFunc,keyMapIgnore,keyMapTrans display
highlight link keyMapDelimiter Typedef

" Function
syntax match keyMapFunc "[_a-zA-Z0-9]\+ \+" contained display

" keywords
syntax match keyMapIgnore "\m&none" contained display
highlight link keyMapIgnore Ignore
syntax match keyMapTrans "\m&trans" contained display
highlight link keyMapTrans Comment

" Arguments, Keys
syntax match keyMapKey "\m[_a-zA-Z0-9]\+ *" contained skipwhite display
highlight link keyMapKey Special

let b:current_syntax = "keymap"

" vim:et ts=4 sts=4 sw=4
