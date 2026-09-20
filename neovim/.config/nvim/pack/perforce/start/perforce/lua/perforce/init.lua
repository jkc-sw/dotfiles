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
  vim.cmd.runtime('plugin/perforce.vim')

  configured = true
  return M
end

return M
