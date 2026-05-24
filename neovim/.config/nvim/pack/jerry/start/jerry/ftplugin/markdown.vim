if exists('b:jerry_markdown_ftplugin_loaded')
    finish
endif
let b:jerry_markdown_ftplugin_loaded = 1

nnoremap <buffer> <leader>th <cmd>call search('^## \d\{4}-\d\{2}-\d\{2}', 'bW')<cr>
nnoremap <buffer> <leader>tn <cmd>call search('^## \d\{4}-\d\{2}-\d\{2}', 'W')<cr>


" A function to copy the stuff
" @brief when working for the journal, need a way to reference the line
" @param oneLiner When true, it will return a 1 liner
" @return - A formatted nvim command to take me here, in powershell
func! TakeMeHereShell(oneLiner)
    let cl = getline('.')
    let fp = expand('%')
    " let fp = substitute(fp, "\\\\", "\\\\\\\\", 'g')
    let fp = substitute(fp, '"', '\\"', 'g')
    let fp = v:lua.string.gsub(fp, '\', '/')
    let fp = v:lua.string.gsub(fp, '.*/[jJ]ournal/', './')
    let cl = substitute(cl, "\\\\", "\\\\\\\\", 'g')
    let cl = substitute(cl, '"', '\\`"', 'g')
    let cl = substitute(cl, '\.', '\\.', 'g')
    let cl = substitute(cl, '\*', '\\\\*', 'g')
    let cl = substitute(cl, '/', '\\/', 'g')
    let cl = substitute(cl, '[', '\\[', 'g')
    let out = "```ps1\n" . 'en ; nvim "' . fp . '" -c "/^' . cl . '/"' . "\n```\n"
    if a:oneLiner
        let out = '`en ; nvim "' . fp . '" -c "/^' . cl . '/"`'
    endif
    echom "TakeMeHereShell copys: " . out
    return out
endfunc

" A function to copy the stuff, but for vim
" @brief when working for the journal, need a way to reference the line
" @return - A formatted nvim command to take me here, in powershell
func! TakeMeHereVim()
    let cl = getline('.')
    let header = ''
    " let cl = substitute(cl, "\\\\", "\\\\\\\\", 'g')
    let cl = substitute(cl, '"', '\\"', 'g')
    let cl = substitute(cl, '\*', '\\\\*', 'g')
    let fp = expand('%')
    " let fp = substitute(fp, "\\\\", "\\\\\\\\", 'g')
    let fp = substitute(fp, '"', '\\"', 'g')
    let fp = substitute(fp, '\*', '\\\\*', 'g')
    let fp = v:lua.string.gsub(fp, '\', '/')
    let fp = v:lua.string.gsub(fp, '.*/[jJ]ournal/', './')
    let out = ''
    if match(cl, '^## ') > -1
        " Then we should include this in the txt
        let out = out . "\n" . cl . "\n\n"
    endif
    let out = out . "```vim\n" . 'execute "e ".fnameescape("' . fp . '") | call search("^' . cl . '")' . "\n```\n"
    echom "TakeMeHereVim copys: " . out
    return out
endfunc

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" @brief Return a formatted text that contains markdown link and powershell
"        script
"        If the label is not given, then it will call Start-Process with link
" @param exe (str) - The program to put in the start-process. Empty to use
"                    default
" @param label (str) - label to put in between [] in markdown
" @param link (str) - link to put in between () in md and argument for exe
" @return str - Formatted text
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! WrapLink(exe, label, link)
    return luaeval("require('jerry.markdown_links').wrap_link(_A[1], _A[2], _A[3])", [a:exe, a:label, a:link])
endfunction

function! s:PromptBrowserLink(browser, label)
    return luaeval("require('jerry.markdown_links').prompt_browser_link_sync(_A[1], _A[2])", [a:browser, a:label])
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" @brief Return a string that contains the output of jf
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! AskUserForJiraTagReturnJfOutput(prefix)
    call inputsave()
    let jtag = input('Jira tag:')
    call inputrestore()
    let jtag = v:lua.string.gsub(jtag, "1~$", "")
    if strlen(jtag) < 1
        echoerr "No jira tag is entered"
    endif
    if has("win32")
        let AskUserForJiraTagReturnJfOutputCmds = ["pwsh.exe", "-NoProfile", "-Command", "Import-Module MyModules00 ; jf '" . jtag . "' -Passthru"]
        let jfoutput = system(AskUserForJiraTagReturnJfOutputCmds)
    else
        let l:ip = getenv('BOXX_IP')
        if l:ip == v:null
            throw 'AskUserForJiraTagReturnJfOutput needs to access env var BOXX_IP, but it is not found'
        endif
        let l:user = getenv('BOXX_USER')
        if l:user == v:null
            throw 'AskUserForJiraTagReturnJfOutput needs to access env var BOXX_USER, but it is not found'
        endif
        let jfoutput = luaeval(printf("vim.system({'jfssh', '%s'}, { text = true, stderr = false }):wait().stdout", jtag))
    endif
    let jfoutput = trim(jfoutput)
    if !empty(a:prefix)
        return a:prefix .. ' ' .. jfoutput
    endif
    return jfoutput
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" @brief Create a tripple backticks blocks
" @return str - Formatted text
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! CodeBlock()
    call inputsave()
    let lang = input('Lang:')
    call inputrestore()
    let txt = "```" . lang . "\n"
    let txt = txt . "```"
    call CodeBlockEnablePasteMode(v:true)
    return txt
endfunction

func! CodeBlockEnablePasteMode(enable)
    if !exists('g:code_block_enable_paste_mode')
        let g:code_block_enable_paste_mode = v:false
    endif
    if a:enable
        set paste
        let g:code_block_enable_paste_mode = v:true
    else
        if g:code_block_enable_paste_mode
            set nopaste
            set expandtab
            let g:code_block_enable_paste_mode = v:false
        endif
    endif
endfun

function! GetDateOffset(dayoffset, prefix)
    let offset = a:dayoffset
    if empty(offset)
        call inputsave()
        let offset = input('Day of offset:')
        call inputrestore()
    endif
    return a:prefix .. strftime('%Y-%m-%d %A', localtime() + str2nr(offset)*60*60*24)
endfunction

function! GetDateOffsetNoDay(...)
    let offset = 0
    if a:0 == 1
        let offset = a:1
    else
        call inputsave()
        let offset = input('Day of offset:')
        call inputrestore()
    endif
    return strftime('%Y-%m-%d', localtime() + offset*60*60*24)
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" @brief Search and replace the bad sharepoint url failing to be stored onto
"        the pdf form
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! SearchAndReplaceInvalidSharePointLink()
    call execute('%s/\((http.*\)\/:\([^:/ ]\):\//\1\/%3A\2%3A\//', "silent!")
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" @brief Return the filename to be saved with title
" @param label (str) - label to put in between [] in markdown, Optional
" @return str - Formatted text
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! AskLabelForPictureNameWithTitle(label)
    call inputsave()
    let nlabel = input('Label:', a:label)
    let nlabel = v:lua.string.gsub(nlabel, "1~$", "")
    call inputrestore()
    let body = AskLabelForPictureName(nlabel)
    let txt = '## ' . nlabel
    let txt = txt . "\n\n" . luaeval("require('jerry.markdown').new_originuuid()")
    let txt = txt . "\n\n" . body
    return txt
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" @brief Return the filename to be saved
" @param label (str) - label to put in between [] in markdown, Optional
" @return str - Formatted text
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! AskLabelForPictureName(label)
    call inputsave()
    let nlabel = a:label
    if empty(a:label)
        let nlabel = input('Label:', nlabel)
    endif
    let nlabel = v:lua.string.gsub(nlabel, "1~$", "")
    " Take label, turn it to lower case, replace space with -
    let defaultPicName = v:lua.string.gsub(tolower(nlabel), ' ', '-')
    let defaultPicName = v:lua.string.gsub(defaultPicName, "'", '')
    let defaultPicName = v:lua.string.gsub(defaultPicName, '[!@#$%%^&,:*()%-=%[%]/\ ?|]+', '-')
    " :let left = 'a88 & &?|- __ a, -h' | let right = 'a88-__-a-h' | let clean = v:lua.string.gsub(left, '[!@#$%%^&,*()%-=%[%]/\ ?|]+', '-') | echom "Ok: " . (right == clean) . ", '" . right . "' == '" . clean . "'"
    let picName = input('Filename:', defaultPicName . '.')
    " " I am not sure how to handle the file extension
    " let picName = v:lua.string.gsub(picName, ".png$", "")
    " " Disable asking for the folder name. Based on my usage, this has never
    " " been used once
    " let folderName = input('Foldername:')
    " let folderName = v:lua.string.gsub(folderName, "1~$", "")
    call inputrestore()
    " " Disable asking for the folder name. Based on my usage, this has never
    " " been used once
    " if empty(folderName)
    "     let folderName = '\Resources\'
    " endif
    " We need to tell if we are in '(work|personal)-*' dir
    let noteParentFolderName = fnamemodify(expand('%:p'), ':h:t')
    let noteTypeDashIndex = match(noteParentFolderName, '-')
    if noteTypeDashIndex < 0
        echoerr "Folder name'" . noteParentFolderName . "' derived from '" . expand('%:p') . "' is not supported. No - is found"
    endif
    let folderName = noteParentFolderName[0:noteTypeDashIndex-1]
    " Generate the filename for the picture to put into the doc
    " It will be placed into the ...\Resources\ folder with timestamp
    let picPathPrefix = folderName . '/' . GetDateOffsetNoDay(0) . '-'
    let link = picPathPrefix . picName
    " Need to change everything to \\
    let link = v:lua.string.gsub(link, "/", "\\")
    if strlen(nlabel) < 1
        let nlabel = link
    endif

    let txt = WrapLink('', nlabel, link)
    let lk = s:PromptBrowserLink('', nlabel)
    if strlen(lk) > 0
        let txt = lk . "\n\n" . txt
    endif
    return txt
endfunction

setlocal wrap spell linebreak

nnoremap <buffer> <leader>.u gg/^-<space>/<cr>}O<c-r>=strftime('- %m/%d/%Y %H:%M:%S %p ')<cr>
nnoremap <buffer> <leader>.b gg/^-<space>/<cr>}O<c-r>=strftime('- %m/%d/%Y %H:%M:%S %p Break ')<cr><esc>A
nnoremap <buffer> <leader>,u "ryygg/^-<space>/<cr>}"rP0d4Wi<c-r>=strftime('- %m/%d/%Y %H:%M:%S %p ')<cr><esc>A<space>
let @c="V/^## \<cr>k\"Ld"

inoreabbrev <buffer> ats <c-r>=GetDateOffset('', '')<cr>
inoreabbrev <buffer> `3 <c-r>=CodeBlock()<cr><Up><End>
inoreabbrev <buffer> pck <c-r>=AskLabelForPictureName('')<cr>
inoreabbrev <buffer> ,p  <c-r>=AskLabelForPictureNameWithTitle('')<cr>
inoreabbrev <buffer> ,t  <c-r>=GetDateOffset('0', '## ')<cr>
inoreabbrev <buffer> ,h  <c-r>=GetDateOffset('', '## ')<cr>
inoreabbrev <buffer> .u  <c-r>=strftime('- %m/%d/%Y %H:%M:%S %p')<cr>
inoreabbrev <buffer> .b  <c-r>=strftime('- %m/%d/%Y %H:%M:%S %p Break')<cr>
inoreabbrev <buffer> .n  +
inoreabbrev <buffer> jff <c-r>=AskUserForJiraTagReturnJfOutput('')<cr>
inoreabbrev <buffer> jf  <c-r>=AskUserForJiraTagReturnJfOutput('Work on')<cr>

lua require('jerry.markdown').setup_buffer()
lua require('jerry.markdown_links').setup_buffer()

augroup markdownFenceHighlight
    autocmd! * <buffer>
    autocmd BufWritePre <buffer> call SearchAndReplaceInvalidSharePointLink()
    autocmd BufWritePre <buffer> silent! %s/Ã‚Â’/'/g
    autocmd InsertLeave <buffer> call CodeBlockEnablePasteMode(v:false)
augroup END

" vim:et ts=4 sts=4 sw=4
