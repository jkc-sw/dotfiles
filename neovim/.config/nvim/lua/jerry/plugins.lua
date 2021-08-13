
return require('packer').startup(function(use)
  -- Packer
  use 'wbthomason/packer.nvim'

  -- Editing
  use 'mbbill/undotree'
  use 'tomtom/tcomment_vim'
  use 'tpope/vim-surround'
  use 'tpope/vim-repeat'
  use 'michaeljsmith/vim-indent-object'
  use 'itchyny/lightline.vim'
  use 'godlygeek/tabular'
  use 'dhruvasagar/vim-testify'

  -- Git
  use 'tpope/vim-fugitive'

  -- Fuzzy stuff
  use {'junegunn/fzf', run = function() vim.fn['fzf#install']() end}
  use 'junegunn/fzf.vim'

  -- Telescope
  use 'nvim-lua/popup.nvim'
  use 'nvim-lua/plenary.nvim'
  use 'nvim-lua/telescope.nvim'
  use 'nvim-telescope/telescope-fzy-native.nvim'

  -- LSP
  use 'neovim/nvim-lspconfig'
  use 'onsails/lspkind-nvim'
  use 'hrsh7th/nvim-compe'
  use 'glepnir/lspsaga.nvim'
  use 'tjdevries/nlua.nvim'
  use 'nvim-lua/lsp_extensions.nvim'
  -- use 'ray-x/lsp_signature.nvim'  -- some ghost buffers remain

  -- Tree sitter
  use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate maintained'}
  use 'nvim-treesitter/playground'
  use 'romgrk/nvim-treesitter-context'
  use 'haringsrob/nvim_context_vt'

  -- Language support
  use 'modille/groovy.vim'
  use 'kergoth/vim-bitbake'
  use 'pprovost/vim-ps1'

  -- Color scheme
  use 'arzg/vim-colors-xcode'
  -- use 'tjdevries/gruvbuddy.nvim'
  -- use 'tjdevries/colorbuddy.vim'
  -- use 'sainnhe/gruvbox-material'
  -- use 'gruvbox-community/gruvbox'
  -- use 'navarasu/onedark.nvim'

  -- Local
  use {vim.loop.os_homedir()..'/repos/focus-side.vim'}
  use {vim.loop.os_homedir()..'/repos/vim-matlab.vim'}

  -- Not working
  -- use 'sheerun/vim-polyglot'

  -- Not used
  -- use 'nvim-lua/completion-nvim'
  -- use 'vim-utils/vim-man'

  -- Maybe future
  -- use 'kyazdani42/nvim-tree.lua'

  -- Always the last
  use 'ryanoasis/vim-devicons'
  use 'kyazdani42/nvim-web-devicons'
end)

-- vim:et sw=2 ts=2 sts=2
