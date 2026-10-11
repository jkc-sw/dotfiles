local M = {}

function M.format(bufnr)
  require('conform').format { bufnr = bufnr or vim.api.nvim_get_current_buf(), lsp_format = 'fallback' }
end

function M.lint(bufnr)
  vim.api.nvim_buf_call(bufnr or vim.api.nvim_get_current_buf(), function()
    require('lint').try_lint 'luacheck'
  end)
end

function M.setup()
  vim.api.nvim_create_user_command('LuaFormat', function()
    M.format()
  end, { desc = 'Format with Conform' })
  vim.api.nvim_create_user_command('LuaLint', function()
    M.lint()
  end, { desc = 'Lint with Luacheck' })
end

return M
