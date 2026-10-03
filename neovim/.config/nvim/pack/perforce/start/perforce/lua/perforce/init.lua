local M = {}

local configured = false

function M.setup(opts)
  opts = opts or {}
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

  require('perforce.keymaps').setup(opts.key_prefix or '<leader>e')

  configured = true
  return M
end

return M
