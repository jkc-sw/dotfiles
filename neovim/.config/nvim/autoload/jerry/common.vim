
" Shorten the path
function! jerry#common#CorrentFileShortener()
    return pathshorten(expand('%'))
endfunction

" Function to get the visual selection
" references: https://vi.stackexchange.com/questions/9888/how-to-pipe-characters-to-cmd
function! jerry#common#GetVisualSelection()
    let [lnum1, col1] = getpos("'<")[1:2]
    let [lnum2, col2] = getpos("'>")[1:2]
    let lines = getline(lnum1, lnum2)
    let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][col1 - 1:]
    return join(lines, "\n")
endfunction

" function to search through files
func! jerry#common#FileFuzzySearch()
    if g:use_fzf
        :Files
    else
        lua require'telescope.builtin'.find_files{find_command = vim.split(vim.env.FZF_DEFAULT_COMMAND, ' ')}
    endif
endfun

" function to search through lines
func! jerry#common#LinesFuzzySearch()
    if g:use_fzf
        :Lines
    else
        lua require'telescope.builtin'.current_buffer_fuzzy_find{}
    endif
endfun

" function to search through buffer
func! jerry#common#BufferFuzzySearch()
    if g:use_fzf
        :Buffers
    else
        lua require'telescope.builtin'.buffers{}
    endif
endfun

" function to search string globally
func! jerry#common#WordFuzzySearch()
    if g:use_fzf
        exec 'Rg '.expand('<cword>')
    else
        lua require('telescope.builtin').grep_string()
    endif
endfun

" function to find references
func! jerry#common#ListSymbols()
    if g:use_fzf
        echom "List symbols from fzf is not supported"
    else
        lua require('telescope.builtin').lsp_document_symbols()
    endif
endfun

" function to search string globally for a string
func! jerry#common#GlobalFuzzySearch()
    if g:use_fzf
        let word = input('Grep For >')
        exec 'Rg '.word
    else
        lua require('telescope.builtin').grep_string({ search = vim.fn.input("Grep For >") })
    endif
endfun

" function to return current pasemode status
func! jerry#common#PasteModeReport()
    if &paste == 1
        return 'paste'
    else
        return ''
    endif
endfun

" function to toggle the paste mode for c-v paste to work
func! jerry#common#TogglePasteMode()
    if &paste == 1
        set nopaste
        set expandtab
    else
        set paste
    endif
endfun

" Trim the whitespaces
fun! jerry#common#TrimWhitespace()
    let ft=&filetype

    " skip for the diff type
    if ft ==? 'diff'
        return
    endif

    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfun

" Close tabs
func! jerry#common#CloseTab()
    " Check how many tabs there is
    if tabpagenr('$') > 1
        tabclose!
    else
        qa!
    endif
endfunc

