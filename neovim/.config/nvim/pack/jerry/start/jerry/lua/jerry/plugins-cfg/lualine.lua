require('lualine').setup {
  options = {
    theme = 'jellybeans'
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { require('jerry.asyncjob').job_report, 'branch', { 'filename', path = 1 } },
    lualine_c = { 'jerry#common#PasteModeReport' },
    lualine_x = { 'fileformat', 'encoding', 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location', { 'diagnostics', sources = { 'nvim_diagnostic' }, sections = { 'error', 'warn' } } },
  },
  inactive_sections = {
    lualine_a = { 'jerry#common#CorrentFileShortener' },
    lualine_b = { 'location' },
    lualine_c = { 'jerry#common#PasteModeReport' },
    lualine_x = { 'progress' },
    lualine_y = {},
    lualine_z = {},
  }
}
