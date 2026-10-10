local M = {}

local configured = false

function M.setup()
  if configured then
    return M
  end

  vim.g.perforce_enabled = true
  vim.filetype.add {
    pattern = {
      ['want.*.rc'] = 'wantrc',
    },
  }
  vim.cmd.runtime 'plugin/perforce.vim'

  -- Annotate the existing Vimscript mappings, preserving RHS and all options.
  for suffix, desc in pairs {
    eo = 'Opened files',
    en = 'Changelist with Jira tags',
    eS = 'Submit buffer spec',
    es = 'Shelve buffer spec',
    ee = 'Edit current file',
    ea = 'Add current file',
    eR = 'Revert current file',
    eN = 'New changelist',
    eO = 'Opened files command output',
    ec = 'Submit changelist and close subtasks',
    eC = 'Submit changelist and close subtasks',
    el = 'Pending changelists',
    eD = 'Filter diff output',
    ep = 'Create patch from edited files',
    ed = 'Get diff',
    eA = 'File history',
    eb = 'File blame',
    ef = 'Close diff windows',
    eu = 'Remove diff entry',
  } do
    local mapping = vim.fn.maparg('<leader>' .. suffix, 'n', false, true)
    mapping.desc = 'Perforce: ' .. desc
    vim.fn.mapset('n', false, mapping)
  end

  configured = true
  return M
end

return M
