return {
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      -- Restore the former withAllGrammars coverage. LazyVim still owns
      -- installation and attachment; exclude parsers upstream cannot support.
      opts.ensure_installed = require('nvim-treesitter.config').norm_languages('all', { unsupported = true })
    end,
  },
}
