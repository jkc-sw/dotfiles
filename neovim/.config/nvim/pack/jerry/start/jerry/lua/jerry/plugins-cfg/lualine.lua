require('lualine').setup {
  options = {
    theme = 'auto',
    globalstatus = true,
    disabled_filetypes = { statusline = { 'snacks_dashboard' } },
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff' },
    lualine_c = {
      { 'diagnostics', sources = { 'nvim_diagnostic' } },
      { 'filename', path = 1 },
      'jerry#common#PasteModeReport',
    },
    lualine_x = { require('jerry.asyncjob').job_report, 'fileformat', 'encoding', 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
  inactive_sections = {
    lualine_a = { 'jerry#common#CorrentFileShortener' },
    lualine_b = { 'location' },
    lualine_c = { 'jerry#common#PasteModeReport' },
    lualine_x = { 'progress' },
    lualine_y = {},
    lualine_z = {},
  },
  extensions = { 'fugitive', 'trouble' },
}
