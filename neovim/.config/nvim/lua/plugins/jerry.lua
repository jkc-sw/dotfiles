return {
  {
    name = 'jerry',
    dir = vim.fn.stdpath('config') .. '/pack/jerry/start/jerry',
    main = 'jerry',
    lazy = false,
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {},
  },
  {
    name = 'perforce',
    dir = vim.fn.stdpath('config') .. '/pack/perforce/start/perforce',
    main = 'perforce',
    enabled = vim.fn.executable('p4') == 1,
    lazy = false,
    opts = { key_prefix = '<localleader>p' },
  },
}
