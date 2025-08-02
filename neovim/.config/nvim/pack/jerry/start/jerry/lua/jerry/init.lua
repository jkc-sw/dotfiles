
require('jerry.global-options')
require('jerry.global-autocommands')
require('jerry.global-funcs')
require('jerry.tmux').setup()
require('jerry.markdown').setup()
require('jerry.lsp.config').setup()

local work_dir = vim.uv.os_homedir() .. '/.config/nvim'
if vim.uv.fs_stat(work_dir) then
  vim.opt.packpath:prepend(work_dir)
end

require('jerry.plugins-cfg.lualine')
require('jerry.plugins-cfg.colorful-menu')
require('jerry.plugins-cfg.blink-cmp')
require('jerry.plugins-cfg.neogit')
require('jerry.plugins-cfg.lspkind')
require('jerry.plugins-cfg.nvim-treesitter')
require('jerry.plugins-cfg.nvim_context_vt')
require('jerry.plugins-cfg.telescope')
require('jerry.plugins-cfg.colorizer')

-- -- Choose one
-- require('jerry.plugins-cfg.markview')
require('jerry.plugins-cfg.render-markdown')

-- Choose one or more
require('jerry.plugins-cfg.avante')
require('jerry.plugins-cfg.codecompanion')
require('jerry.plugins-cfg.copilot')
