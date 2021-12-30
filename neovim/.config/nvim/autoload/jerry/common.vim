
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

	if !exists('g:jc_getvisualselection_dedent')
        let g:jc_getvisualselection_dedent = 1
    endif
	if !exists('g:jc_getvisualselection_skipempty')
        let g:jc_getvisualselection_skipempty = 1
    endif

    " If a line has tab, replace it and warn user
    let ts = &tabstop
    let tpad = repeat(' ', ts)
    for ii in range(len(lines))
        if match(lines[ii], '\t') > -1
            let lines[ii] = substitute(lines[ii], '\t', tpad, 'g')
        endif
    endfor

    " Find the line index that is not empty
    let nonempty_startlidx = 0
    for ii in range(len(lines))
        if !empty(lines[ii])
            break
        endif

        let nonempty_startlidx = nonempty_startlidx + 1
    endfor

    " Calculate the ident for each line
    let idents = []
    let minident = -1
    for ii in range(len(lines))
        " If empty, put 0
        let thisident = 0
        if empty(lines[ii])
            let idents = add(idents, 0)
        else
            let thisident = match(lines[ii], '[^ ]')
            let idents = add(idents, thisident)

            " If this is the first iteration, assign it
            if minident < 0
                let minident = thisident
            endif

            " Find max
            if thisident < minident
                let minident = thisident
            endif
        endif
    endfor

    " Skip all the empty lines except the begining or the end
    if g:jc_getvisualselection_skipempty == 1
        let lth = len(lines)
        let ii = nonempty_startlidx
        let last_ident = idents[0]

        while ii < lth
            " Need to compare line before and after for indent
            let removeEmptyLine = v:true
            " If not out of the range
            if (ii + 1) < (lth)
                " if the ident is not the same as the last line, keep the
                " empty line
                if last_ident != idents[ii + 1]
                    let removeEmptyLine = v:false
                endif
            endif

            if empty(lines[ii]) && (ii != lth - 1) && removeEmptyLine
                " keep the last empty line, remove rest
                call remove(lines, ii)
                " Remove the idents as well
                call remove(idents, ii)
                let lth = lth - 1
            else
                " If line not empty, remember this as the last ident
                let last_ident = idents[ii]
            endif

            let ii = ii + 1
        endwhile
    endif

    " Run assert
    if len(lines) != len(idents)
        echoerr 'Need to ensure lines and idents are same length, lines has '.len(lines).' and idents has '.len(idents)
    endif

	if g:jc_getvisualselection_dedent == 1
		" Find the first char index not a space, substract that from every line
        " let trim_amount = idents[nonempty_startlidx]
        let trim_amount = minident
		if trim_amount > 0
			for ii in range(len(lines))
                if ii < nonempty_startlidx
                    continue
                endif

                let ident = idents[ii]
                let ident = min([ident, trim_amount])

				let lines[ii] = lines[ii][ident:]
                let idents[ii] = ident
			endfor
		endif
	endif

    return join(lines, "\r")
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

