
return require('packer').startup(function(use)
  -- Packer
  use 'wbthomason/packer.nvim'

  -- Editing
  use 'mbbill/undotree'
  -- use 'JoosepAlviste/nvim-ts-context-commentstring'
  use 'numToStr/Comment.nvim'
  -- use 'tomtom/tcomment_vim'
  use 'machakann/vim-sandwich'
  use 'michaeljsmith/vim-indent-object'
  use 'godlygeek/tabular'
  use 'dhruvasagar/vim-testify'

  -- Status line
  use 'hoob3rt/lualine.nvim'

  -- Git
  use 'tpope/vim-fugitive'
  use {
    "TimUntersberger/neogit",
    requires = 'nvim-lua/plenary.nvim'
  }
  -- use 'tpope/vim-fugitive'

  -- Fuzzy stuff
  use {'junegunn/fzf', run = function() vim.fn['fzf#install']() end}
  use 'junegunn/fzf.vim'

  -- Telescope
  use 'nvim-lua/popup.nvim'
  use 'nvim-lua/plenary.nvim'
  use 'nvim-lua/telescope.nvim'
  -- use 'nvim-telescope/telescope-fzy-native.nvim'
  use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }

  -- LSP
  use {
    'neovim/nvim-lspconfig',
    -- commit = '10ad0cca1b83713ed98ed4cb7ea60f2ea8e55c49'
  }
  use 'onsails/lspkind-nvim'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-nvim-lua'
  use 'hrsh7th/nvim-cmp'
  use 'tjdevries/nlua.nvim'

  -- Tree sitter
  use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}
  use 'nvim-treesitter/playground'
  use 'romgrk/nvim-treesitter-context'
  use 'haringsrob/nvim_context_vt'

  -- Language support
  use 'modille/groovy.vim'
  use 'kergoth/vim-bitbake'
  use 'pprovost/vim-ps1'

  -- Color
  use 'norcalli/nvim-colorizer.lua'
  use 'sainnhe/gruvbox-material'

  -- Local
  use {vim.loop.os_homedir()..'/repos/focus-side.vim'}
  use {vim.loop.os_homedir()..'/repos/vim-matlab.vim'}

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
end)

-- vim:et sw=2 ts=2 sts=2
