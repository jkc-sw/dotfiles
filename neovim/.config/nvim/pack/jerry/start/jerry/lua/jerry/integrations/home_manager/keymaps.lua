local M = {}

-- Prefer the attached LSP workspace, then a Git root, then the current directory.
-- This does not change :pwd or affect the shared Perforce configuration.
local function root()
  local filename = vim.api.nvim_buf_get_name(0)
  for _, client in ipairs(vim.lsp.get_clients { bufnr = 0 }) do
    if client.config.root_dir then
      return client.config.root_dir
    end
  end
  return vim.fs.root(filename ~= '' and filename or vim.fn.getcwd(), { '.git' }) or vim.fn.getcwd()
end

function M.setup()
  local snacks = require 'snacks'
  local function map(mode, lhs, rhs, desc, opts)
    desc = require('jerry.keymap_categories').describe(lhs, desc, mode)
    vim.keymap.set(mode, lhs, rhs, vim.tbl_extend('force', { silent = true, desc = desc }, opts or {}))
  end
  local function pick(source, cwd)
    return function()
      snacks.picker[source] { cwd = cwd and vim.fn.getcwd() or root() }
    end
  end

  for _, key in ipairs { 'h', 'j', 'k', 'l' } do
    map('n', '<C-' .. key .. '>', '<C-w>' .. key, 'Go to ' .. key .. ' window', { remap = true })
  end
  map('n', '<C-Up>', '<cmd>resize +2<cr>', 'Increase window height')
  map('n', '<C-Down>', '<cmd>resize -2<cr>', 'Decrease window height')
  map('n', '<C-Left>', '<cmd>vertical resize -2<cr>', 'Decrease window width')
  map('n', '<C-Right>', '<cmd>vertical resize +2<cr>', 'Increase window width')
  map('n', '<leader>ww', '<C-w>p', 'Other window')
  map('n', '<leader>wd', '<C-w>c', 'Delete window')
  map('n', '<leader>-', '<C-w>s', 'Split below')
  map('n', '<leader>|', '<C-w>v', 'Split right')
  map({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", 'Down', { expr = true })
  map({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", 'Up', { expr = true })
  map('x', '<', '<gv', 'Indent left')
  map('x', '>', '>gv', 'Indent right')
  map({ 'n', 'i', 'x' }, '<C-s>', '<cmd>write<cr><esc>', 'Save file')
  map('n', '<Esc>', '<cmd>nohlsearch<cr>', 'Clear search highlight')
  map(
    'n',
    '<leader>ur',
    '<cmd>nohlsearch<bar>diffupdate<bar>normal! <C-l><cr>',
    'Redraw / clear highlights / update diff'
  )
  map('n', 'n', "'Nn'[v:searchforward].'zv'", 'Next search result', { expr = true })
  map('n', 'N', "'nN'[v:searchforward].'zv'", 'Previous search result', { expr = true })
  for _, mode in ipairs { 'x', 'o' } do
    map(mode, 'n', "'Nn'[v:searchforward]", 'Next search result', { expr = true })
    map(mode, 'N', "'nN'[v:searchforward]", 'Previous search result', { expr = true })
  end
  map('n', '<leader>K', '<cmd>normal! K<cr>', 'Keyword help')

  map('n', '<leader><space>', pick 'files', 'Find files (root)')
  map('n', '<leader>ff', pick 'files', 'Find files (root)')
  map('n', '<leader>fF', pick('files', true), 'Find files (cwd)')
  map('n', '<leader>,', pick 'buffers', 'Buffers')
  map('n', '<leader>fb', pick 'buffers', 'Buffers')
  map('n', '<leader>fr', pick 'recent', 'Recent files')
  map('n', '<leader>e', function()
    snacks.explorer { cwd = root() }
  end, 'Explorer (root)')
  map('n', '<leader>E', function()
    snacks.explorer { cwd = vim.fn.getcwd() }
  end, 'Explorer (cwd)')
  map('n', '<leader>fe', function()
    snacks.explorer { cwd = root() }
  end, 'Explorer (root)')
  map('n', '<leader>fE', function()
    snacks.explorer { cwd = vim.fn.getcwd() }
  end, 'Explorer (cwd)')
  map('n', '<leader>fn', '<cmd>enew<cr>', 'New file')
  map('n', '<leader>/', pick 'grep', 'Grep (root)')
  map('n', '<leader>sg', pick 'grep', 'Grep (root)')
  map('n', '<leader>sG', pick('grep', true), 'Grep (cwd)')
  map({ 'n', 'x' }, '<leader>sw', pick 'grep_word', 'Search word/selection (root)')
  map('n', '<leader>sb', pick 'lines', 'Buffer lines')
  map('n', '<leader>sh', pick 'help', 'Help pages')
  map('n', '<leader>sH', pick 'highlights', 'Highlights')
  map('n', '<leader>su', pick 'undo', 'Undo history')
  map('n', '<leader>sk', pick 'keymaps', 'Keymaps')
  map('n', '<leader>sd', pick 'diagnostics', 'Diagnostics')
  map('n', '<leader>sD', pick 'diagnostics_buffer', 'Buffer diagnostics')
  map('n', '<leader>ss', pick 'lsp_symbols', 'Document symbols')
  map('n', '<leader>sS', pick 'lsp_workspace_symbols', 'Workspace symbols')
  map('n', '<leader>sq', pick 'qflist', 'Quickfix list')
  map('n', '<leader>st', pick 'todo_comments', 'Todo comments')
  map({ 'n', 'x' }, '<leader>sr', function()
    local extension = vim.bo.buftype == '' and vim.fn.expand '%:e'
    require('grug-far').open {
      transient = true,
      prefills = { filesFilter = extension and extension ~= '' and '*.' .. extension or nil },
    }
  end, 'Search and replace')
  map('n', '<leader>sR', function()
    snacks.picker.resume()
  end, 'Resume picker')
  map('n', '<leader>n', function()
    snacks.picker.notifications()
  end, 'Notification history')

  map('n', '<S-h>', '<cmd>BufferLineCyclePrev<cr>', 'Previous buffer')
  map('n', '<S-l>', '<cmd>BufferLineCycleNext<cr>', 'Next buffer')
  map('n', '[b', '<cmd>BufferLineCyclePrev<cr>', 'Previous buffer')
  map('n', ']b', '<cmd>BufferLineCycleNext<cr>', 'Next buffer')
  map('n', '<leader>bb', '<cmd>buffer #<cr>', 'Other buffer')
  map('n', '<leader>bd', function()
    snacks.bufdelete()
  end, 'Delete buffer')
  map('n', '<leader>bo', function()
    snacks.bufdelete.other()
  end, 'Delete other buffers')
  map('n', '<leader>bD', '<cmd>bdelete<cr>', 'Delete buffer and window')
  map('n', '<leader>bp', '<cmd>BufferLineTogglePin<cr>', 'Toggle buffer pin')

  map({ 'n', 'x', 'o' }, 's', function()
    require('flash').jump()
  end, 'Flash')
  map({ 'n', 'x', 'o' }, 'S', function()
    require('flash').treesitter()
  end, 'Flash Treesitter')
  map('n', '<leader>gg', function()
    snacks.lazygit { cwd = root() }
  end, 'Lazygit (root)')
  map('n', '<leader>gG', function()
    snacks.lazygit()
  end, 'Lazygit (cwd)')
  map('n', '<leader>gs', pick 'git_status', 'Git status')
  map('n', '<leader>gd', pick 'git_diff', 'Git diff (hunks)')
  map('n', '<leader>gD', function()
    snacks.picker.git_diff { cwd = root(), base = 'origin', group = true }
  end, 'Git diff (origin)')
  map('n', '<leader>gb', pick 'git_log_line', 'Git blame line')
  map('n', '<leader>gf', pick 'git_log_file', 'Git file history')
  map('n', '<leader>gl', pick 'git_log', 'Git log')
  map('n', '<leader>gL', pick('git_log', true), 'Git log (cwd)')
  map('n', '<leader>gp', pick 'gh_pr', 'GitHub pull requests (open)')
  map('n', '<leader>gP', function()
    snacks.picker.gh_pr { cwd = root(), state = 'all' }
  end, 'GitHub pull requests (all)')
  map('n', ']h', function()
    require('gitsigns').nav_hunk 'next'
  end, 'Next hunk')
  map('n', '[h', function()
    require('gitsigns').nav_hunk 'prev'
  end, 'Previous hunk')
  map('n', '<leader>ghs', function()
    require('gitsigns').stage_hunk()
  end, 'Stage hunk')
  map('n', '<leader>ghr', function()
    require('gitsigns').reset_hunk()
  end, 'Reset hunk')
  map('n', '<leader>ghp', function()
    require('gitsigns').preview_hunk_inline()
  end, 'Preview hunk')
  map('n', '<leader>ghb', function()
    require('gitsigns').blame_line { full = true }
  end, 'Blame line')

  map('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', 'Diagnostics (Trouble)')
  map('n', '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', 'Buffer diagnostics (Trouble)')
  map('n', '<leader>xQ', '<cmd>Trouble qflist toggle<cr>', 'Quickfix (Trouble)')
  map('n', '<leader>xL', '<cmd>Trouble loclist toggle<cr>', 'Location list (Trouble)')
  map('n', '<leader>xq', function()
    local command = vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen
    local ok, err = pcall(command)
    if not ok then
      vim.notify(err, vim.log.levels.ERROR)
    end
  end, 'Quickfix list')
  map('n', '<leader>xl', function()
    local command = vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen
    local ok, err = pcall(command)
    if not ok then
      vim.notify(err, vim.log.levels.ERROR)
    end
  end, 'Location list')
  map('n', '<leader>xt', '<cmd>Trouble todo toggle<cr>', 'Todo (Trouble)')
  map('n', '<leader>cs', '<cmd>Trouble symbols toggle<cr>', 'Symbols (Trouble)')
  map('n', '<leader>cS', '<cmd>Trouble lsp toggle<cr>', 'LSP locations (Trouble)')
  local function diagnostic_jump(forward, severity)
    return function()
      vim.diagnostic.jump {
        count = (forward and 1 or -1) * vim.v.count1,
        severity = severity,
        float = true,
      }
    end
  end
  map('n', '[d', diagnostic_jump(false), 'Previous diagnostic')
  map('n', ']d', diagnostic_jump(true), 'Next diagnostic')
  map('n', '[e', diagnostic_jump(false, vim.diagnostic.severity.ERROR), 'Previous error')
  map('n', ']e', diagnostic_jump(true, vim.diagnostic.severity.ERROR), 'Next error')
  map('n', '[w', diagnostic_jump(false, vim.diagnostic.severity.WARN), 'Previous warning')
  map('n', ']w', diagnostic_jump(true, vim.diagnostic.severity.WARN), 'Next warning')
  map('n', '<leader>cd', vim.diagnostic.open_float, 'Line diagnostics')
  map('n', '[q', '<cmd>cprev<cr>', 'Previous quickfix item')
  map('n', ']q', '<cmd>cnext<cr>', 'Next quickfix item')
  map('n', '[t', function()
    require('todo-comments').jump_prev()
  end, 'Previous todo comment')
  map('n', ']t', function()
    require('todo-comments').jump_next()
  end, 'Next todo comment')

  local function format()
    require('conform').format { async = true, lsp_format = 'fallback' }
  end
  map({ 'n', 'x' }, '<leader>cf', format, 'Format buffer/selection')
  map({ 'n', 'x' }, '<leader>cF', function()
    require('conform').format { formatters = { 'injected' }, timeout_ms = 3000 }
  end, 'Format injected languages')
  map('n', '<leader>cl', pick 'lsp_config', 'LSP configurations')
  map('n', '<leader>cr', vim.lsp.buf.rename, 'Rename')
  map({ 'n', 'x' }, '<leader>ca', vim.lsp.buf.code_action, 'Code action')
  map('n', 'gd', pick 'lsp_definitions', 'Go to definition')
  map('n', 'gD', vim.lsp.buf.declaration, 'Go to declaration')
  map('n', 'gr', pick 'lsp_references', 'References')
  map('n', 'gI', pick 'lsp_implementations', 'Go to implementation')
  map('n', 'gy', pick 'lsp_type_definitions', 'Go to type definition')
  map('n', 'K', vim.lsp.buf.hover, 'Hover')
  map('n', 'gK', vim.lsp.buf.signature_help, 'Signature help')
  map('i', '<C-k>', vim.lsp.buf.signature_help, 'Signature help')
  map('n', '<leader>ui', vim.show_pos, 'Inspect position')

  snacks.toggle
    .new({
      name = 'Autoformat',
      get = function()
        return vim.g.autoformat ~= false
      end,
      set = function(value)
        vim.g.autoformat = value
      end,
    })
    :map '<leader>uf'
  snacks.toggle
    .new({
      name = 'Buffer autoformat',
      get = function()
        return vim.b.autoformat ~= false
      end,
      set = function(value)
        vim.b.autoformat = value
      end,
    })
    :map '<leader>uF'
  snacks.toggle.option('wrap', { name = 'Wrap' }):map '<leader>uw'
  snacks.toggle.option('relativenumber', { name = 'Relative numbers' }):map '<leader>uL'
  snacks.toggle.diagnostics():map '<leader>ud'
  map('n', '<leader>un', function()
    snacks.notifier.hide()
  end, 'Dismiss notifications')
  map('n', '<leader>qs', function()
    require('persistence').load()
  end, 'Restore session')
  map('n', '<leader>qS', function()
    require('persistence').select()
  end, 'Select session')
  map('n', '<leader>ql', function()
    require('persistence').load { last = true }
  end, 'Restore last session')
  map('n', '<leader>qd', function()
    require('persistence').stop()
  end, 'Stop saving session')
  map('n', '<leader>qq', '<cmd>qa<cr>', 'Quit all')
  map('n', '<leader><tab>l', '<cmd>tablast<cr>', 'Last tab')
  map('n', '<leader><tab>o', '<cmd>tabonly<cr>', 'Close other tabs')
  map('n', '<leader><tab>f', '<cmd>tabfirst<cr>', 'First tab')
  map('n', '<leader><tab><tab>', '<cmd>tabnew<cr>', 'New tab')
  map('n', '<leader><tab>d', '<cmd>tabclose<cr>', 'Close tab')
  map('n', '<leader><tab>]', '<cmd>tabnext<cr>', 'Next tab')
  map('n', '<leader><tab>[', '<cmd>tabprevious<cr>', 'Previous tab')
  map({ 'n', 't' }, '<C-/>', function()
    snacks.terminal.toggle(nil, { cwd = root() })
  end, 'Terminal (root)')
  map('n', '<leader>ft', function()
    snacks.terminal.toggle(nil, { cwd = root() })
  end, 'Terminal (root)')
end

return M
