require('jerry.global-funcs')

require('jerry.plugins-cfg.lualine')
require('jerry.plugins-cfg.colorful-menu')
require('jerry.plugins-cfg.blink-cmp')
require('jerry.plugins-cfg.neogit')
require('jerry.plugins-cfg.lspkind')
require('jerry.plugins-cfg.nvim-treesitter')
require('jerry.plugins-cfg.nvim_context_vt')
require('jerry.plugins-cfg.telescope')
require('jerry.plugins-cfg.colorizer')
-- require('jerry.plugins-cfg.markview')
-- require('jerry.plugins-cfg.render-markdown')

require('jerry.markdown').setup()
require('jerry.lsp.config').setup()

vim.filetype.add({
  extensions = {
    inc = 'bitbake',
    keymap = 'keymap',
  }
})
