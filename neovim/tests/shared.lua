local root = '/root/.local/share/jerry-dotfiles/neovim/.config/nvim/pack/'
vim.opt.rtp:append(root .. 'jerry/start/jerry')
vim.opt.rtp:append(root .. 'perforce/start/perforce')
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'
local original = {}
for _, option in ipairs({ 'signcolumn', 'undodir', 'clipboard', 'grepprg' }) do
  original[option] = vim.o[option]
end
assert(not vim.g.jerry_enabled)
local jerry = require('jerry')
assert(not vim.g.jerry_enabled, 'require must have no setup side effects')
jerry.setup()
jerry.setup()
for option, value in pairs(original) do
  assert(vim.o[option] == value, 'distribution option overridden: ' .. option)
end
assert(not package.loaded['jerry.lua-tools'], 'custom formatter must not load')
assert(not package.loaded['jerry.integrations.home_manager'])
assert(vim.fn.maparg(' gg', 'n') == '', 'legacy Git binding leaked')
assert(vim.fn.maparg(' b', 'n') == '', 'legacy buffer binding leaked')
vim.cmd('args /tmp/a\\ b.lua /tmp/c.lua')
vim.cmd.ArgsToQF()
local qf = vim.fn.getqflist()
assert(#qf == 2 and vim.api.nvim_buf_get_name(qf[1].bufnr) == '/tmp/a b.lua')
vim.cmd('filetype plugin on')
vim.cmd.edit('/tmp/journal.md')
assert(vim.b.jerry_markdown_setup_done)
assert(vim.fn.maparg('ats', 'i', true):find('get_date_offset', 1, true), 'journal date abbreviation overwritten')
vim.cmd.enew()
vim.bo.filetype = 'lua'
assert(vim.fn.maparg('ats', 'i', true) == '', 'Markdown abbreviation leaked')
vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'vim.g.jerry_eval_test = 42' })
vim.fn.maparg(' jel', 'n', false, true).callback()
assert(vim.g.jerry_eval_test == 42, 'custom Lua evaluation failed')
vim.bo.modified = false
require('perforce').setup({ key_prefix = '<localleader>p' })
assert(vim.fn.maparg(' eo', 'n') == '', 'Perforce shadows explorer prefix')
assert(vim.fn.maparg('\\po', 'n') ~= '')
assert(not package.loaded['telescope'])
require('jerry.date_resolver').run_tests()
assert(not table.concat(vim.fn.readfile('/tmp/result'), '\n'):find('Some tests failed', 1, true))
print('Shared plugin checks passed')
