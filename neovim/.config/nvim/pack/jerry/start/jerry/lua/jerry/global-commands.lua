

-- Help: ArgsToQF
-- Copies the current :args list into the quickfix list, replacing its contents.
-- Quickfix entries take literal filenames, including spaces and special characters.
-- Usage: :ArgsToQF (then :copen to view the quickfix list)
vim.api.nvim_create_user_command("ArgsToQF", function()
  local items = vim.tbl_map(function(filename)
    return { filename = filename, lnum = 1, col = 1 }
  end, vim.fn.argv())
  vim.fn.setqflist({}, 'r', { title = 'Argument list', items = items })
end, { desc = 'Replace quickfix list with current :args files' })

-- vim:et sw=2 ts=2 sts=2
