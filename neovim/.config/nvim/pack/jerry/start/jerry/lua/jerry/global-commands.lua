-- Usage: :ArgsToQF, then :copen. Quickfix takes literal filenames, not Ex
-- command arguments: escaping them would change names with spaces or symbols.
vim.api.nvim_create_user_command('ArgsToQF', function()
  local items = vim.tbl_map(function(filename)
    return { filename = filename, lnum = 1 }
  end, vim.fn.argv())
  vim.fn.setqflist({}, 'r', { title = 'Argument list', items = items })
end, { desc = 'Replace quickfix list with the current argument list' })

-- vim:et sw=2 ts=2 sts=2
