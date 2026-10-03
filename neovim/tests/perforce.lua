vim.opt.rtp:append('/root/.local/share/jerry-dotfiles/neovim/.config/nvim/pack/perforce/start/perforce')
vim.fn.mkdir('/tmp/p4-bin', 'p')
vim.fn.writefile({
  '#!/bin/sh',
  'if [ "$P4_TEST_FAIL" = 1 ]; then echo "test failure" >&2; exit 1; fi',
  'if [ "$2" = opened ]; then',
  '  printf "... depotFile //depot/a b.txt\\n"',
  'else',
  '  printf "... depotFile //depot/a b.txt\\n... path /tmp/a b.txt\\n"',
  'fi',
}, '/tmp/p4-bin/p4')
vim.fn.setfperm('/tmp/p4-bin/p4', 'rwx------')
vim.env.PATH = '/tmp/p4-bin:' .. vim.env.PATH
local selected = false
vim.ui.select = function(items, _, callback)
  assert(items[1] == '//depot/a b.txt')
  selected = true
  callback(items[1])
end
require('perforce.p4').opened()
assert(vim.wait(5000, function() return vim.api.nvim_buf_get_name(0) == '/tmp/a b.txt' end))
assert(selected)
local notice
vim.notify = function(message) notice = message end
vim.env.P4_TEST_FAIL = '1'
require('perforce.p4').opened()
assert(vim.wait(5000, function() return notice ~= nil end))
assert(notice:find('test failure', 1, true))
print('Perforce picker checks passed (fake p4, no server access)')
