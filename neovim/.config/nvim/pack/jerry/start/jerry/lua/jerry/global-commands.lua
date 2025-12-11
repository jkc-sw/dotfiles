

-- Help: ArgsToQF
-- Copies the current :args list into the quickfix list, replacing its contents.
-- Filenames are escaped via fnameescape to handle spaces and special characters.
-- Usage: :ArgsToQF (then :copen to view the quickfix list)
vim.api.nvim_create_user_command("ArgsToQF", function()
  vim.fn.setqflist(vim.tbl_map(vim.fn.fnameescape, vim.fn.argv()), "r")
end, { desc = 'Replace quickfix list with escaped current :args files' })

-- vim:et sw=2 ts=2 sts=2
