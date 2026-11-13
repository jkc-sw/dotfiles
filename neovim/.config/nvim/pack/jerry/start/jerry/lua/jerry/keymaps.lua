local M = {}

function M.setup()
  -- Retain personal overrides alongside actions without a LazyVim shortcut.
  -- Apply these after the integrator's defaults.
  -- LazyVim's punctuation undo breaks interrupt abbreviations such as ,n,
  -- .u and code;. Keep punctuation in the same insert sequence.
  for _, key in ipairs { ',', '.', ';' } do
    pcall(vim.keymap.del, 'i', key)
  end

  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, {
      noremap = true,
      silent = true,
      desc = require('jerry.keymap_categories').describe(lhs, desc, mode),
    })
  end

  map({ 'n', 'x' }, ';', ':', 'Enter command line')
  map({ 'n', 'x' }, ':', ';', 'Repeat character find')

  map('n', '<leader>pp', '<cmd>call jerry#common#TogglePasteMode()<CR>', 'Toggle paste mode')
  map('n', '<leader>r', "<cmd>silent exec '!tswitch -c nv'<CR>", 'Open side pane')
  map('n', '<leader>,.', "<cmd>call execute(getline('.'), '')<CR>", 'Evaluate Vimscript line')
  map(
    'v',
    '<leader>,.',
    ":<C-u>lua require('jerry.sourcer').eval_vimscript"
      .. "(table.concat(vim.fn['jerry#common#GetVisualSelectionAsList'](), '\\n'))<CR>",
    'Evaluate Vimscript selection'
  )
  map('n', '<leader>,p', "<cmd>call luaeval(getline('.'), '')<CR>", 'Evaluate Lua line')
  map(
    'v',
    '<leader>,p',
    ":<C-u>lua require('jerry.sourcer').eval_lua"
      .. "(table.concat(vim.fn['jerry#common#GetVisualSelectionAsList'](), '\\n'))<CR>",
    'Evaluate Lua selection'
  )
  map('n', '<leader>T', '<cmd>lua SL()<CR>', 'Send line to Neovim terminal')
  map('v', '<leader>T', ':<C-u>lua SV()<CR>', 'Send selection to Neovim terminal')

  -- Repeat the last shell command in another tmux / zellij pane.
  for lhs, spec in pairs {
    ['<leader>oe'] = { ':.+1', 'Repeat command in next pane' },
    ['<leader>ou'] = { ':.-1', 'Repeat command in previous pane' },
    ['<leader>oo'] = { ':+.1', 'Repeat command in next window' },
    ['<leader>oa'] = { ':-.1', 'Repeat command in previous window' },
  } do
    map('n', lhs, function()
      require('jerry.tmux').repeat_last_command(spec[1])
    end, spec[2])
  end

  map(
    'n',
    '<leader>ty',
    "<cmd>lua require('jerry.sourcer').lua_sourcer('SOURCE_THESE_LUAS_START', 'SOURCE_THESE_LUAS_END')<CR>",
    'Source marked Lua block'
  )
  map(
    'n',
    '<leader>ti',
    "<cmd>lua require('jerry.sourcer').vim_sourcer('SOURCE_THESE_VIMS_START', 'SOURCE_THESE_VIMS_END')<CR>",
    'Source marked Vimscript block'
  )
  map('n', '<leader>tp', "<cmd>lua require('jerry.marker').mark_these('MARK_THIS_PLACE')<CR>", 'Mark text region')
  map('n', '<leader>gQ', function()
    for _, client in ipairs(vim.lsp.get_clients()) do
      client:stop()
    end
  end, 'Stop all LSP clients')

  map('n', '<leader>Hl', '<cmd>so $VIMRUNTIME/syntax/hitest.vim<CR>', 'Show syntax highlight test')
  map('v', '<leader>p', '"0p', 'Paste last yank (register 0)')
  map('n', '<leader>fm', 'vip:g/\\|/Tab/\\|/<CR>', 'Align pipe-separated paragraph')
end

return M
