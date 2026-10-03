vim.cmd.cd('/root/workspace')
for _, value in ipairs({ false, '', "printf 'file with spaces.lua' | sort" }) do
  vim.env.FZF_DEFAULT_COMMAND = value or nil
  vim.fn['jerry#common#FileFuzzySearch']()
  local prompt = vim.api.nvim_get_current_buf()
  local picker = require('telescope.actions.state').get_current_picker(prompt)
  assert(picker, 'file picker did not open')
  assert(vim.wait(10000, function()
    return picker.manager and picker.manager:num_results() > 0
  end, 50), 'file picker did not discover workspace files')
  require('telescope.actions').close(prompt)
end
assert(vim.v.errmsg == '', vim.v.errmsg)
vim.fn.writefile({ 'File picker checks passed: unset, empty, and shell-style FZF_DEFAULT_COMMAND' }, '/tmp/jerry-file-picker-result')
