return {
  {
    name = 'jerry',
    dir = vim.fn.stdpath 'config' .. '/pack/jerry/start/jerry',
    lazy = false,
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('jerry').setup()
    end,
  },
  {
    name = 'perforce',
    dir = vim.fn.stdpath 'config' .. '/pack/perforce/start/perforce',
    lazy = false,
    dependencies = { 'jerry' },
    config = function()
      require('perforce').setup()
    end,
  },
}
