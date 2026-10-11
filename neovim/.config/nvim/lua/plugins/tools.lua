return {
  { 'tpope/vim-fugitive', cmd = { 'Git', 'G', 'Gdiffsplit', 'Gvdiffsplit', 'Gedit' } },
  { 'machakann/vim-sandwich' },
  { 'michaeljsmith/vim-indent-object' },
  { 'godlygeek/tabular', cmd = { 'Tabularize', 'Tab' } },
  {
    'NeogitOrg/neogit',
    cmd = 'Neogit',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {},
  },
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    opts = {},
    config = function(_, opts)
      require('telescope').setup(opts)
      require('telescope').load_extension 'fzf'
    end,
  },
  { 'jkc-sw/focus-side.vim' },
  { 'jkc-sw/vim-matlab', ft = 'matlab' },
  {
    'olimorris/codecompanion.nvim',
    tag = 'v17.33.0', -- Retain the existing pin while upstream changes its API.
    cmd = { 'CodeCompanion', 'CodeCompanionChat', 'CodeCompanionActions' },
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter', 'nvim-telescope/telescope.nvim' },
    opts = {
      display = { action_palette = { provider = 'telescope' } },
      strategies = { chat = { adapter = 'azure_openai' }, inline = { adapter = 'azure_openai' } },
      -- The built-in adapter reads AZURE_OPENAI_API_KEY and AZURE_OPENAI_ENDPOINT.
      -- Supply private adapter/model overrides through the local configuration.
    },
  },
}
