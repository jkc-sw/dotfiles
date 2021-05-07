
" function to get list of terminal id
func! jerry#term#GetTerminalIdList()
    return uniq(map(filter(getbufinfo(), 'has_key(v:val.variables, "terminal_job_id")'), 'v:val.variables.terminal_job_id'))
endfunc

" function to get the terminal id from index
func! jerry#term#GetTerminalId()
    let tlist = jerry#term#GetTerminalIdList()
    if empty(tlist)
        split | terminal
        hide
        let tlist = jerry#term#GetTerminalIdList()
    endif

    return tlist[0]
endfunc

" function to create terminal mapping
func! jerry#term#NewTerminalMapping(k, cmd)
    let c = "<cmd>call chansend(jerry#term#GetTerminalId(), '" . a:cmd . "'." . '"\n"' . ")<cr>"
    echom 'c = '.c
    call nvim_set_keymap('n', a:k, c, {'silent': v:true, 'noremap': v:true})
endfunc
