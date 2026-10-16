return {
  { 'michaeljsmith/vim-indent-object' },
  { 'godlygeek/tabular', cmd = { 'Tabularize', 'Tab' } },
  {
    'NeogitOrg/neogit',
    cmd = 'Neogit',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {},
  },
  { 'jkc-sw/focus-side.vim' },
  { 'jkc-sw/vim-matlab', ft = 'matlab' },
}
