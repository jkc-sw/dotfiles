
command! P4 call perforce#HomePage()

nnoremap <silent> <leader>eo <cmd> lua require('perforce.p4').opened{}<CR>
nnoremap <leader>en :call perforce#GetChangelistWithJiraTags()<CR>
nnoremap <leader>eS <cmd>w ! p4 submit -i -r<CR>
nnoremap <leader>es <cmd>w ! p4 shelve -i<CR>
nnoremap <leader>ep <cmd>! p4 sync ./...\#head<CR>
nnoremap <leader>ee <cmd>exec "!p4 edit " . shellescape(perforce#SanitizePerforceFilename(expand('%')), 1)<CR>
nnoremap <leader>ea <cmd>exec "!p4 add -f " . shellescape(perforce#SanitizePerforceFilename(expand('%')), 1)<CR>
nnoremap <leader>eR <cmd>exec "!p4 revert " . shellescape(perforce#SanitizePerforceFilename(expand('%')), 1)<CR>
nnoremap <leader>eN <cmd>tabnew <BAR> set noexpandtab <bar> read ! p4 change -o<CR>/<<CR>C
nnoremap <leader>eO <cmd>lua RT('p4', {'opened'})<CR>
nnoremap <leader>ec <cmd>call perforce#SubmitChangelistAndCloseSubtasks()<CR>
nnoremap <leader>eC <cmd>call perforce#SubmitChangelistAndCloseSubtasks()<CR>
nnoremap <leader>el <cmd>! p4 changes -m 10 -L -s pending --me -c "$P4CLIENT"<CR>
nnoremap <leader>eD <cmd>call perforce#FilterDiffOutput()<CR>
nnoremap <leader>ep <cmd>call perforce#NewPatchFromEdited()<CR>
nnoremap <leader>ed <cmd>call perforce#GetDiff()<CR>
nnoremap <leader>eA <cmd>call perforce#ShowHistory()<CR>
nnoremap <leader>ef <cmd>diffoff <BAR> windo quit!<CR>
