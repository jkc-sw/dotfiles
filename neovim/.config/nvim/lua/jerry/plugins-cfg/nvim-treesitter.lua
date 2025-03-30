require('nvim-treesitter.configs').setup {
  sync_install = false,
  auto_install = false,
  context_commentstring = {
    enable = false,
  },
  highlight = {
    enable = true,
    disable = { 'cpp' }
  },
  indent = {
    enable = false,
    disable = { 'python' }
  }
}
