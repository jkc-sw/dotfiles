local snacks = require 'snacks'

require('bufferline').setup {
  options = {
    diagnostics = 'nvim_lsp',
    always_show_bufferline = false,
    close_command = function(bufnr)
      snacks.bufdelete(bufnr)
    end,
    right_mouse_command = function(bufnr)
      snacks.bufdelete(bufnr)
    end,
    offsets = { { filetype = 'snacks_layout_box' } },
  },
}

require('gitsigns').setup {
  signs = {
    add = { text = '▎' },
    change = { text = '▎' },
    delete = { text = '' },
    topdelete = { text = '' },
    changedelete = { text = '▎' },
    untracked = { text = '▎' },
  },
}
require('flash').setup { modes = { char = { enabled = false } } }
require('mini.ai').setup { n_lines = 500 }
require('mini.pairs').setup {}
require('trouble').setup {}
require('grug-far').setup { headerMaxWidth = 80 }
require('todo-comments').setup {}
require('persistence').setup {}

local which_key = require 'which-key'
which_key.setup { preset = 'helix', delay = 300 }
which_key.add {
  { '<leader>b', group = 'buffer' },
  { '<leader>c', group = 'code' },
  { '<leader>f', group = 'file/find' },
  { '<leader>g', group = 'git' },
  { '<leader>gh', group = 'hunks' },
  { '<leader>q', group = 'quit/session' },
  { '<leader>s', group = 'search' },
  { '<leader>u', group = 'UI' },
  { '<leader>w', group = 'windows' },
  { '<leader>x', group = 'diagnostics/quickfix' },
  { '<leader><tab>', group = 'tabs' },
  { '<leader>,', group = 'buffers / evaluation', mode = { 'n', 'x' } },
  { '<leader>.', group = 'journal' },
  { '<leader>e', group = 'explorer / Perforce' },
  { '<leader>H', group = 'highlight tests' },
  { '<leader>n', group = 'notifications / code blocks' },
  { '<leader>o', group = 'tmux repeat' },
  { '<leader>p', group = 'paste / snippets' },
  { '<leader>t', group = 'text tools', mode = { 'n', 'x' } },
}
