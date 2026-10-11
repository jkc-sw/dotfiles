return {
  {
    'nvim-treesitter/nvim-treesitter',
    opts = {
      -- Extend the native parser set for the retained language workflows.
      ensure_installed = {
        'bitbake',
        'cmake',
        'go',
        'gomod',
        'gosum',
        'gowork',
        'groovy',
        'latex',
        'matlab',
        'nix',
        'powershell',
        'rust',
      },
    },
  },
}
