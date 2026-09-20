return {
  {
    name = 'jerry',
    dir = vim.fn.stdpath('config') .. '/pack/jerry/start/jerry',
    lazy = false,
    config = function()
      require('jerry').setup()
    end,
  },
  {
    name = 'perforce',
    dir = vim.fn.stdpath('config') .. '/pack/perforce/start/perforce',
    lazy = false,
    config = function()
      require('perforce').setup()
    end,
  },
}
