local M = {}

function M.setup(prefix)
  local mappings = {
    { 'o', function() require('perforce.p4').opened() end, 'Opened files' },
    { 'n', ':call perforce#GetChangelistWithJiraTags()<CR>', 'Changelist with Jira tags' },
    { 'S', '<cmd>w ! p4 submit -i -r<CR>', 'Submit and reopen' },
    { 's', '<cmd>w ! p4 shelve -i<CR>', 'Shelve' },
    { 'e', [[<cmd>exec "!p4 edit " . shellescape(perforce#SanitizePerforceFilename(expand('%')), 1)<CR>]], 'Edit file' },
    { 'a', [[<cmd>exec "!p4 add -f " . shellescape(expand('%'), 1)<CR>]], 'Add file' },
    { 'R', [[<cmd>exec "!p4 revert " . shellescape(perforce#SanitizePerforceFilename(expand('%')), 1)<CR>]], 'Revert file' },
    { 'N', '<cmd>tabnew <BAR> set noexpandtab <bar> read ! p4 change -o<CR>/<<CR>C', 'New changelist' },
    { 'O', function() require('jerry.asyncjob').run_to_tab('p4', { 'opened' }) end, 'Opened files in tab' },
    { 'c', '<cmd>call perforce#SubmitChangelistAndCloseSubtasks()<CR>', 'Submit changelist' },
    { 'C', '<cmd>call perforce#SubmitChangelistAndCloseSubtasks()<CR>', 'Submit changelist' },
    { 'l', '<cmd>! p4 changes -m 10 -L -s pending --me -c "$P4CLIENT"<CR>', 'Pending changelists' },
    { 'D', '<cmd>call perforce#FilterDiffOutput()<CR>', 'Filtered diff' },
    -- The old Vimscript defined ep twice; NewPatchFromEdited was the effective
    -- mapping. Preserve it rather than silently changing ep back to p4 sync.
    { 'p', '<cmd>call perforce#NewPatchFromEdited()<CR>', 'Patch from edited files' },
    { 'd', '<cmd>call perforce#GetDiff()<CR>', 'Diff file' },
    { 'A', '<cmd>call perforce#ShowHistory()<CR>', 'File history' },
    { 'b', '<cmd>call perforce#ShowBlame()<CR>', 'File blame' },
    { 'f', '<cmd>diffoff <BAR> windo quit!<CR>', 'Close diff' },
    { 'u', '<cmd>call perforce#RemoveThisDiffEntryFromFile()<CR>', 'Remove diff entry' },
  }
  for _, mapping in ipairs(mappings) do
    vim.keymap.set('n', prefix .. mapping[1], mapping[2], {
      silent = mapping[1] == 'o',
      desc = 'Perforce: ' .. mapping[3],
    })
  end
end

return M
