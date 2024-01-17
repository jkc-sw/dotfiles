let s:PERFORCE_STATUS_PAGE_NAME = 'PerforceStatus'
let s:CHANGELIST_LINE_PREFIX = '# pending changelist'
let s:SUBMITTED_CHANGELIST_LINE_PREFIX = '# submitted changelist'

let s:PERFORCE_RESERVED_KEYWORDS_AND_SUBS = [
    \ ['@\(40\)\@!', '%40'],
    \ ['#\(23\)\@!', '%23'],
    \ ['*\(2A\)\@!', '%2A'],
    \ ['%\(25\)\@!', '%25'],
    \ ]

" @brief A filename might not be put in as is, since it might contains the
"        reserved keywords
" @param p - The raw filepath as it appears on the file system
" @return sanitized filename for perforce command line
func! perforce#SanitizePerforceFilename(p)
    let ret = a:p
    for group in s:PERFORCE_RESERVED_KEYWORDS_AND_SUBS
        let ret = substitute(ret, group[0], group[1], 'g')
    endfor
    return ret
endfunc


if executable('p4') == 1
    func! perforce#ShowBlame()
        let pth = perforce#SanitizePerforceFilename(expand('%'))
        let l:his = system("p4 annotate -u -I -db '" .. pth .. "' | tr '\r' '\n'")
        tabnew
        set noexpandtab
        put =l:his
        normal! ggdd
    endfunc

    func! perforce#ShowHistory()
        let pth = perforce#SanitizePerforceFilename(expand('%'))
        let l:his = system("p4 annotate -a -u -I -db '" .. pth .. "' | tr '\r' '\n'")
        tabnew
        set noexpandtab
        put =l:his
        normal! ggdd
    endfunc


    " @brief Remove an entry from the diff file from output of the `p4 diff`
    func! perforce#RemoveThisDiffEntryFromFile()
        let p_orig = @/
        let lidx = search('^--- \/\/', 'nW')
        " If no match, or at the end, do nothing
        if lidx < 1
            let [_, lidx, _, _] = getpos('$')
        else
            let lidx = lidx - 1
        endif
        " Get current line
        let [bnr, cidx, _, _] = getpos('.')
        " Delete the lines
        let c = '' . cidx . ',' . lidx . ' ' . 'd'
        call execute(c, 'silent')
        " restore the search
        let @/ = p_orig
    endfunc


    func! perforce#GetDiff()
        let ft=&filetype
        let ori = expand('%')
        let pth = shellescape(perforce#SanitizePerforceFilename(ori), 1)
        exec 'tab sp'
        " leftabove vnew  " left | right
        leftabove new
        exec 'set filetype='.ft
        exec 'read ! p4 print -q ' .. pth .. '\#head'
        normal! ggdd
        setlocal nomodified readonly noswapfile
        windo difft
    endfunc


    function! perforce#ReplaceBufferWithJiraTag()
        let l:tags = system('Invoke-JerryJira.ps1 -Format')
        silent execute 'g/<.*>/s/<.*>/\=l:tags'
    endfunction


    function! perforce#GetChangelist()
        let l:cl = system('p4 change -o')
        tabnew
        set noexpandtab
        put =l:cl
    endfunction


    function! perforce#SubmitChangelistAndCloseSubtasks()

		let do = v:false
        let choice = confirm("Close all subtasks?", "&Yes\n&No", 2)
        if choice == 0
            echom "Aborted"
            return
        elseif choice == 1
			let do = v:true
        endif

        write ! p4 submit -i
        if v:shell_error != 0
            echo "See above error"
            return
        endif

		if do
            lua require('jerry.asyncjob').run_to_tab('Invoke-JerryJira.ps1', {'-CloseSubTask'})
		endif

    endfunction


    function! perforce#GetChangelistWithJiraTags()
        call perforce#GetChangelist()
        call perforce#ReplaceBufferWithJiraTag()
    endfunction


    function! s:IssueP4Cmd(cmd)
        let l:out = systemlist(a:cmd)
        if v:shell_error
            call s:ThrowPerforceException(
                        \'perforce: p4 cmd failed. Maybe need to login again?'
                        \)
        end

        return l:out
    endfunc


    function! s:ParseZTagOutput(content)
        let l:ret = []
        let l:key = ''
        let l:each = {}
        let l:start = ''
        let l:last_is_multi = v:false

        for line in a:content
            if line =~ '\.\.\. '
                if l:last_is_multi
                    let l:ret[-1][l:key] = trim(l:ret[-1][l:key], "\n", 2)
                    let l:last_is_multi = v:false
                endif

                let l:matches = matchlist(line, '... \([^[:blank:]]\+\) \(.*\)')

                let l:key = l:matches[1]
                if empty(l:start)
                    let l:start = l:key
                endif

                if empty(l:start) || l:key == l:start
                    let l:ret += [{}]
                end

                if !empty(l:matches[2])
                    let l:val = l:matches[2]
                    let l:ret[-1][l:key] = l:val
                else
                    let l:ret[-1][l:key] = v:true
                endif
            else
                if empty(l:start)
                    continue
                endif

                let l:last_is_multi = v:true

                let l:ret[-1][l:key] = l:ret[-1][l:key] . "\n" . line
            endif
        endfor

        if l:last_is_multi
            let l:ret[-1][l:key] = trim(l:ret[-1][l:key], "\r\n", 2)
            let l:last_is_multi = v:false
        endif

        return l:ret
    endfunc


    function! s:ThrowPerforceException(msg)
        throw 'perforce:'.a:msg
    endfunc


    function! s:CreateNewPage()
        if !bufexists(s:PERFORCE_STATUS_PAGE_NAME)
            let l:bufferId = bufadd(s:PERFORCE_STATUS_PAGE_NAME)
        endif
        silent exec 'botright split | buf '.s:PERFORCE_STATUS_PAGE_NAME

        " Taken from fugitive
        setlocal noro ma nomodeline buftype=nowrite

        silent exec '%d'
        call s:AppendContent('Perfore Status Page')
    endfunc


    function! s:MakePageReadonly()
        if bufexists(s:PERFORCE_STATUS_PAGE_NAME)
            silent exec 'norm! ggdd'
            " Taken from fugitive
            setlocal nomodified readonly noswapfile
            if &bufhidden ==# ''
              setlocal bufhidden=delete
            endif
        endif
    endfunc


    function! s:GetClientInfo()
        let l:out = s:IssueP4Cmd('p4 -ztag client -o')

        let b:ClientInfo = s:ParseZTagOutput(l:out)[0]
        return b:ClientInfo
    endfunc


    function! s:ChangeLists(type, maxNum)
        let l:cmd = 'p4 -ztag changes -l ' .
                    \' -s '.a:type.' '

        if a:type ==# 'submitted'
            let l:cmd = l:cmd . '-m ' . string(a:maxNum)
        else
            let l:cmd = l:cmd . '--me '
        endif

        let l:cmd = l:cmd . ' ' . b:ClientInfo['Root'] . '/...'
        let l:out = s:IssueP4Cmd(l:cmd)

        let l:changes = s:ParseZTagOutput(l:out)

        let l:ret = []
        for each in l:changes
            let l:new_each = copy(each)

            let l:cmd = 'p4 -ztag describe -s ' . each['change']
            let l:out = s:IssueP4Cmd(l:cmd)
            let l:describe = s:ParseZTagOutput(l:out)[0]
            let l:new_each['depotFiles'] = []

            for [key, val] in items(l:describe)
                if key =~ 'depotFile'
                    let l:new_each['depotFiles'] += [val]
                endif
            endfor

            let l:cmd = 'p4 -ztag describe -s -S ' . each['change']
            let l:out = s:IssueP4Cmd(l:cmd)
            let l:describe = s:ParseZTagOutput(l:out)[0]
            let l:new_each['shelvedFiles'] = []

            for [key, val] in items(l:describe)
                if key =~ 'depotFile'
                    let l:new_each['shelvedFiles'] += [val]
                endif
            endfor

            let l:ret += [l:new_each]
        endfor

        return l:ret
    endfunc


    function! s:AppendContent(content)
        silent exec 'put =a:content'

        " WARN: This method doesn't handle the newline that well
        " silent call append(line('$'), a:content)
    endfunc


    function! s:OpenedFiles()
        let l:cmd = 'p4 -ztag opened'
        let l:out = s:IssueP4Cmd(l:cmd)
        return s:ParseZTagOutput(l:out)
    endfunc


    function! s:PrintClientInfo()
        let l:clientOut = s:GetClientInfo()
        call s:AppendContent('')
        call s:AppendContent('Client: '.get(l:clientOut, 'Client', 'N/A'))
        call s:AppendContent('Root:   '.get(l:clientOut, 'Root', 'N/A'))
        call s:AppendContent('Stream: '.get(l:clientOut, 'Stream', 'N/A'))
    endfunc


    function! s:PrintSeparator()
        call s:AppendContent(
                    \'========================================'
                    \. '========================================'
                    \)
    endfunc


    function! s:PrintOpenChangeLists()
        let l:changelistOut = s:ChangeLists('pending', 0)
        if !empty(l:changelistOut)
            call s:AppendContent('')
            call s:PrintSeparator()
        endif
        for changelist in l:changelistOut
            let l:msg = s:CHANGELIST_LINE_PREFIX . ' ' . changelist['change']
            let l:fileListStr = ''

            if !empty(changelist['depotFiles'])
                for each in changelist['depotFiles']
                    let l:fileListStr = l:fileListStr
                                \. "\n  "
                                \. each
                endfor
            endif

            if !empty(changelist['shelvedFiles'])
                let l:msg = l:msg . " (have shelved)"

                for each in changelist['shelvedFiles']
                    let l:fileListStr = l:fileListStr
                                \. "\n  "
                                \. "(shelved) "
                                \. each
                endfor
            endif

            let l:msg = l:msg  . "\n..." . substitute(
                        \trim(changelist['desc']), '\n', "\n...", 'g'
                        \)
            if !empty(l:fileListStr)
                let l:msg = l:msg . l:fileListStr
            endif

            call s:AppendContent(l:msg)
            call s:AppendContent('')
        endfor
    endfunc


    function! s:PrintSubmittedChangeLists()
        let l:changelistOut = s:ChangeLists('submitted', 5)
        if !empty(l:changelistOut)
            call s:AppendContent('')
            call s:PrintSeparator()
        endif
        for changelist in l:changelistOut
            let l:msg = s:SUBMITTED_CHANGELIST_LINE_PREFIX
                        \. ' '
                        \. changelist['change']
            let l:fileListStr = ''

            let l:msg = l:msg  . "\n..." . substitute(
                        \trim(changelist['desc']), '\n', "\n...", 'g'
                        \)

            if !empty(changelist['depotFiles'])
                for each in changelist['depotFiles']
                    let l:fileListStr = l:fileListStr
                                \. "\n  "
                                \. each
                endfor
            endif

            if !empty(l:fileListStr)
                let l:msg = l:msg . l:fileListStr
            endif

            call s:AppendContent(l:msg)
            call s:AppendContent('')
        endfor
    endfunc


    function! s:PrintOpenedFiles()
        let l:openedFiles = s:OpenedFiles()
        if !empty(l:openedFiles)
            call s:AppendContent('')
            call s:PrintSeparator()
        endif
        for each in l:openedFiles
            call s:AppendContent(
                \printf(
                \    'change %s (%s) -> %s',
                \    each['change'],
                \    each['action'],
                \    each['clientFile']
                \)
                \)
        endfor
    endfunc


    function! perforce#HomePage()
        if executable('p4') != 1
            echoerr 'No "p4" executable found in the PATH'
            return
        endif

        if !exists('$P4CLIENT')
            echoerr 'No P4CLIENT env var present'
            return
        endif

        try
            call s:CreateNewPage()

            call s:PrintClientInfo()

            call s:PrintOpenChangeLists()

            call s:PrintOpenedFiles()

            " call s:PrintSubmittedChangeLists()

            call s:MakePageReadonly()
        catch /^perforce:/
            echoerr v:exception
        endtry
    endfunc

    function! perforce#NewPatchFromEdited()
        tabnew
        exec 'silent read ! p4 diff -du5'
        call perforce#MakeP4dPatchFile()
        call perforce#ApplyVimDiffOutput()
    endfunc

    function! perforce#FilterDiffOutput()
        tabnew
        exec 'silent read ! p4 diff -du5 -dw -db'
        call perforce#ApplyVimDiffOutput()
    endfunc
endif

function! perforce#ApplyVimDiffOutput()
    set filetype=diff
    exec 'silent g/^---.*\(hdl_prj\|hdl\/hdlsrc\)/.,/^--- \/\//-1 d'
    norm! ggdd
    setlocal nomodified readonly noswapfile
    syn on
endfunc

function! perforce#MakeP4dPatchFile()
    exec 'silent g/^---/norm! j^wyt#k^wvt#pj^t#a.new'
endfunc

if executable('black') == 1
    function! perforce#FormatBlack()
        !black %
    endfunction
endif

if executable('python3') == 1
    function! perforce#FormatJson()
        ! python3 -c "import json;f=open('%','r');c=json.load(f);f.close();f=open('%','w');json.dump(c,f,indent=4);f.close()"
    endfunction
endif

if executable('pylint') == 1
    function! perforce#LintPy()
        tab new | silent r ! pylint #
    endfunction
endif

if executable('pwsh') == 1
    function! perforce#LintPowershell()
        tab new | silent r ! pwsh -Command 'Invoke-ScriptAnalyzer -Path "#"'
    endfunction
endif


