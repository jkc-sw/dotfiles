
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

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" @brief Return a formatted text that contains markdown link and powershell
"        script
"        If the label is not given, then it will call Start-Process with link
" @param exe (str) - The program to put in the start-process. Empty to use
"                    default
" @param label (str) - label to put in between [] in markdown
" @param link (str) - link to put in between () in md and argument for exe
" @return str - Formatted text
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! WrapLink(exe, label, link)
    if strlen(a:link) < 1
        return ''
    endif
    let link = trim(a:link)
    let link = trim(link, '"')
    let link = v:lua.string.gsub(link, "1~$", "")
    let alabel = a:label
    let alabel = v:lua.string.gsub(alabel, "1~$", "")
    let txt = 'Use below to handle this: ' . alabel . "\n"
    " let txt = txt . "\n"
    let txt = txt . "```ps1\n"
    let csp1 = "Start-Process \"" . a:exe . "\" -ArgumentList '\"" . link . "\"'\n"
    if strlen(a:exe) < 1
        let csp1 = "Start-Process \"" . link . "\"\n"
        let csp1 = csp1 . "tnpreview \"" . link . "\"\n"
    endif
    let csp2 = "cpnew \"" . link . "\"\n"
    let txt = txt . csp1
    let txt = txt . csp2
    let txt = txt . "```"
    " Make all the backslash forwardslash
    let txt = v:lua.string.gsub(txt, '\', '/')
    return txt
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" @brief Return a formatted text that contains markdown link and powershell
"        script
" @param label (str) - label to put in between [] in markdown. Empty will use
"                      link
" @return str - Formatted text
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! WrapLinkUsingMarkdown(label)
    call inputsave()
    if strlen(a:label) < 1
        let nlabel = input('Label:', a:label)
        let nlabel = v:lua.string.gsub(nlabel, "1~$", "")
    else
        let nlabel = a:label
    endif
    let link = input('Url:')
    call inputrestore()
    if strlen(link) < 1
        return ''
    endif
    if strlen(nlabel) < 1
        let nlabel = link
    endif
    let txt = '[' . nlabel . '](' . link . ')'
    return txt
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" @brief Return a formatted text that contains markdown link and powershell
"        script
" @param browser (str) - The path to the broswer
" @param label (str) - label to put in between [] in markdown. Empty will use
"                      link
" @return str - Formatted text
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! WrapLinkWithBrowser(browser, label)
    let browser = a:browser
    call inputsave()
    if strlen(a:label) < 1
        let nlabel = input('Label:', a:label)
        let nlabel = v:lua.string.gsub(nlabel, "1~$", "")
    else
        let nlabel = a:label
    endif
    let link = input('Url:')
    call inputrestore()
    if strlen(nlabel) < 1
        let nlabel = link
        " " Special code that will search backward for header and put it here,
        " " max 5 lines
        " for ii in [-1, -2, -3, -4, -5]
        "     " If empty, next
        "     " Stop the search if it is neither empty or starts with #
        "     if v:string.search
        " endfor
    endif
    return WrapLink(browser, nlabel, link)
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" @brief Return a string that contains the output of jf
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! AskUserForJiraTagReturnJfOutput(prefix)
    call inputsave()
    let jtag = input('Jira tag:')
    call inputrestore()
    let jtag = v:lua.string.gsub(jtag, "1~$", "")
    if strlen(jtag) < 1
        echoerr "No jira tag is entered"
    endif
    if has("win32")
        let g:AskUserForJiraTagReturnJfOutputCmds = ["pwsh.exe", "-NoProfile", "-Command", "Import-Module MyModules00 ; jf '" . jtag . "' -Passthru"]
    else
        let l:ip = getenv('BOXX_IP')
        if l:ip == v:null
            throw 'AskUserForJiraTagReturnJfOutput needs to access env var BOXX_IP, but it is not found'
        endif
        if empty(g:boxx_user)
            let g:boxx_user = system(['pass', 'system-user'])
        endif
        let cred = g:boxx_user .. ':' .. l:ip
        let g:AskUserForJiraTagReturnJfOutputCmds = ['ssh', '-p', '2222', cred, 'zsh', '-c', '". /home/chenkua/.zshrc ; jf ' .. jtag .. '"']
    endif
    let jfoutput = system(g:AskUserForJiraTagReturnJfOutputCmds)
    let jfoutput = trim(jfoutput)
    if !empty(a:prefix)
        return a:prefix .. ' ' .. jfoutput
    endif
    return jfoutput
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" @brief Return a formatted text that contains markdown link and powershell
"        script and the markdown title
" @return str - Formatted text
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! WrapLinkAndMarkdownTitle(browser, label)
    let browser = a:browser
    call inputsave()
    let nlabel = input('Label:', a:label)
    let nlabel = v:lua.string.gsub(nlabel, "1~$", "")
    let link = input('Url:')
    call inputrestore()
    if strlen(nlabel) < 1
        let nlabel = link
    endif
    let txt = '## ' . nlabel . "\n\n"
    let txt = txt . WrapLink(browser, nlabel, link)
    return txt
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" @brief Return a formatted text that contains markdown link and powershell
"        script, In edge
" @param label (str) - label to put in between [] in markdown, Optional
" @return str - Formatted text
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! AskLabelLinkWithEdge(...)
    let browser = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
    let label = ''
    if a:0 == 1
        let label = a:1
    endif
    return WrapLinkWithBrowser(browser, label)
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" @brief Create a tripple backticks blocks
" @return str - Formatted text
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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

augroup CodeBlockEnterExitInsertMode
    autocmd!
    autocmd! InsertLeave *.md call CodeBlockEnablePasteMode(v:false)
augroup END

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

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" @brief Search and replace the bad sharepoint url failing to be stored onto
"        the pdf form
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! SearchAndReplaceInvalidSharePointLink()
    call execute('%s/\((http.*\)\/:\([^:/ ]\):\//\1\/%3A\2%3A\//', "silent!")
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" @brief Return the filename to be saved with title
" @param label (str) - label to put in between [] in markdown, Optional
" @return str - Formatted text
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! AskLabelForPictureNameWithTitle(label)
    call inputsave()
    let nlabel = input('Label:', a:label)
    let nlabel = v:lua.string.gsub(nlabel, "1~$", "")
    call inputrestore()
    let body = AskLabelForPictureName(nlabel)
    let txt = '## ' . nlabel
    let txt = txt . "\n\n" . body
    return txt
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" @brief Return the filename to be saved
" @param label (str) - label to put in between [] in markdown, Optional
" @return str - Formatted text
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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
    let lk = WrapLinkWithBrowser('', nlabel)
    if strlen(lk) > 0
        let txt = lk . "\n\n" . txt
    endif
    return txt
endfunction

augroup markdownFenceHighlight
    autocmd!
    autocmd BufWritePre                   *.md call SearchAndReplaceInvalidSharePointLink()
    autocmd BufWritePre                   *.md silent! %s/Ã‚Â’/'/g
    autocmd BufEnter,BufWinEnter,TabEnter *.md nnoremap <leader>.u gg/^-<space>/<cr>}O<c-r>=strftime('- %m/%d/%Y %H:%M:%S %p ')<cr>
    autocmd BufEnter,BufWinEnter,TabEnter *.md nnoremap <leader>.b gg/^-<space>/<cr>}O<c-r>=strftime('- %m/%d/%Y %H:%M:%S %p Break ')<cr><esc>A
    autocmd BufEnter,BufWinEnter,TabEnter *.md nnoremap <leader>,u "ryygg/^-<space>/<cr>}"rP0d4Wi<c-r>=strftime('- %m/%d/%Y %H:%M:%S %p ')<cr><esc>A<space>
    autocmd BufEnter,BufWinEnter,TabEnter *.md let @c="V/^## \<cr>k\"Ld"
    autocmd BufEnter,BufWinEnter,TabEnter *.md set wrap spell
    autocmd BufEnter,BufWinEnter,TabEnter *.md iabbrev ats <c-r>=GetDateOffset('', '')<cr>
    autocmd BufEnter,BufWinEnter,TabEnter *.md iabbrev `3 <c-r>=CodeBlock()<cr><Up><End>
    autocmd BufEnter,BufWinEnter,TabEnter *.md iabbrev cnk <c-r>=WrapLinkWithBrowser('', 'Crucible')<cr>
    autocmd BufEnter,BufWinEnter,TabEnter *.md iabbrev enk <c-r>=AskLabelLinkWithEdge('Open in Edge')<cr>
    autocmd BufEnter,BufWinEnter,TabEnter *.md iabbrev gnk <c-r>=WrapLinkWithBrowser('', 'Github')<cr>
    autocmd BufEnter,BufWinEnter,TabEnter *.md iabbrev ink <c-r>=WrapLinkWithBrowser('', 'Link')<cr>
    autocmd BufEnter,BufWinEnter,TabEnter *.md iabbrev mnk <c-r>=WrapLinkAndMarkdownTitle('', '')<cr>
    autocmd BufEnter,BufWinEnter,TabEnter *.md iabbrev pck <c-r>=AskLabelForPictureName('')<cr>
    autocmd BufEnter,BufWinEnter,TabEnter *.md iabbrev ,p  <c-r>=AskLabelForPictureNameWithTitle('')<cr>
    autocmd BufEnter,BufWinEnter,TabEnter *.md iabbrev nk  <c-r>=WrapLinkWithBrowser('', '')<cr>
    autocmd BufEnter,BufWinEnter,TabEnter *.md iabbrev nj  <c-r>=WrapLinkUsingMarkdown('')<cr>
    autocmd BufEnter,BufWinEnter,TabEnter *.md iabbrev onk <c-r>=WrapLinkWithBrowser('', 'Open in Default App')<cr>
    autocmd BufEnter,BufWinEnter,TabEnter *.md iabbrev pnk <c-r>=WrapLinkWithBrowser('', 'Project')<cr>
    autocmd BufEnter,BufWinEnter,TabEnter *.md iabbrev rnk <c-r>=WrapLinkWithBrowser('', 'Reference')<cr>
    autocmd BufEnter,BufWinEnter,TabEnter *.md iabbrev sck <c-r>=WrapLinkWithBrowser('', 'Slack')<cr>
    autocmd BufEnter,BufWinEnter,TabEnter *.md iabbrev spt <c-r>=WrapLinkWithBrowser('', 'SharePoint')<cr>
    autocmd BufEnter,BufWinEnter,TabEnter *.md iabbrev tnk <c-r>=WrapLinkWithBrowser('', 'Topic')<cr>
    autocmd BufEnter,BufWinEnter,TabEnter *.md iabbrev ynk <c-r>=WrapLinkWithBrowser('', 'Youtube')<cr>
    autocmd BufEnter,BufWinEnter,TabEnter *.md iabbrev ,t  <c-r>=GetDateOffset('0', '## ')<cr>
    autocmd BufEnter,BufWinEnter,TabEnter *.md iabbrev ,h  <c-r>=GetDateOffset('', '## ')<cr>
    autocmd BufEnter,BufWinEnter,TabEnter *.md iabbrev .u  <c-r>=strftime('- %m/%d/%Y %H:%M:%S %p')<cr>
    autocmd BufEnter,BufWinEnter,TabEnter *.md iabbrev .b  <c-r>=strftime('- %m/%d/%Y %H:%M:%S %p Break')<cr>
    autocmd BufEnter,BufWinEnter,TabEnter *.md iabbrev .n  +
    autocmd BufEnter,BufWinEnter,TabEnter *.md iabbrev jff <c-r>=AskUserForJiraTagReturnJfOutput('')<cr>
    autocmd BufEnter,BufWinEnter,TabEnter *.md iabbrev jf  <c-r>=AskUserForJiraTagReturnJfOutput('Work on')<cr>
augroup END

" vim:et ts=4 sts=4 sw=4
