
return {
  -- Editing
  'mbbill/undotree',
  -- use 'JoosepAlviste/nvim-ts-context-commentstring'
  'numToStr/Comment.nvim',
  -- use 'tomtom/tcomment_vim'
  'machakann/vim-sandwich',
  'michaeljsmith/vim-indent-object',
  'godlygeek/tabular',
  'dhruvasagar/vim-testify',

  -- Status line
  'hoob3rt/lualine.nvim',

  -- Git
  'tpope/vim-fugitive',
  {
    "TimUntersberger/neogit",
    dependencies = {
      'nvim-lua/plenary.nvim'
    }
  },
  -- use 'tpope/vim-fugitive'

  -- Fuzzy stuff
  'junegunn/fzf.vim',

  -- Telescope
  'nvim-lua/popup.nvim',
  'nvim-lua/plenary.nvim',
  'nvim-lua/telescope.nvim',
  -- use 'nvim-telescope/telescope-fzy-native.nvim'
  -- {
  --   'nvim-telescope/telescope-fzf-native.nvim',
  --   build = 'make'
  -- },

  -- LSP
  {
    'neovim/nvim-lspconfig',
    -- commit = '10ad0cca1b83713ed98ed4cb7ea60f2ea8e55c49'
  },

  'onsails/lspkind-nvim',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-nvim-lua',
  'hrsh7th/nvim-cmp',
  'tjdevries/nlua.nvim',

  -- Tree sitter
  {
    'nvim-treesitter/nvim-treesitter',
    -- -- not needed for the nix home manager config
    -- build = ':TSUpdate'
  },
  'nvim-treesitter/playground',
  -- use 'romgrk/nvim-treesitter-context'
  'haringsrob/nvim_context_vt',

  -- Language support
  'modille/groovy.vim',
  'kergoth/vim-bitbake',
  'pprovost/vim-ps1',

  -- Color
  'norcalli/nvim-colorizer.lua',
  'sainnhe/gruvbox-material',

  -- Local
  -- {
  --   dir = vim.uv.os_homedir()..'/repos/focus-side.vim'
  -- },
  'jkc-sw/focus-side.vim',
  -- {
  --   dir = vim.uv.os_homedir()..'/repos/vim-matlab.vim'
  -- },
  'jkc-sw/vim-matlab',
  {
    dir = jkcswDotfilesGithub .. '/neovim/.config/nvim/pack/perforce/start/perforce'
  },

  -- for work
  {
    dir = vim.uv.os_homedir() .. '/.config/nvim/pack/mks/start/mks'
  },
  -- Not working
  -- use 'sheerun/vim-polyglot'

  -- Not used
  -- use 'nvim-lua/completion-nvim'
  -- use 'vim-utils/vim-man'
  -- use 'itchyny/lightline.vim'
  -- use 'ryanoasis/vim-devicons'
  -- use 'kyazdani42/nvim-web-devicons'
  -- use 'tpope/vim-surround'  -- No longer being maintained
  -- -- [UNMAINTAINED] Lspsaga hasn't been maintained for a long time.
  -- use 'glepnir/lspsaga.nvim'
  -- use 'ray-x/lsp_signature.nvim'  -- some ghost buffers remain
  -- use 'tpope/vim-repeat'

  -- Maybe future
  -- use 'kyazdani42/nvim-tree.lua'
}

-- vim:et sw=2 ts=2 sts=2
