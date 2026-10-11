local icons = require 'jerry.integrations.home_manager.icons'
local path = require 'jerry.integrations.home_manager.statusline'
local snacks = require 'snacks'
local symbols = require('trouble').statusline {
  mode = 'symbols',
  groups = {},
  title = false,
  filter = { range = true },
  format = '{kind_icon}{symbol.name:Normal}',
  hl_group = 'lualine_c_normal',
}

require('lualine').setup {
  options = {
    theme = 'auto',
    globalstatus = true,
    disabled_filetypes = { statusline = { 'dashboard', 'alpha', 'ministarter', 'snacks_dashboard' } },
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch' },
    lualine_c = {
      path.root_dir(),
      {
        'diagnostics',
        symbols = {
          error = icons.diagnostics.Error,
          warn = icons.diagnostics.Warn,
          info = icons.diagnostics.Info,
          hint = icons.diagnostics.Hint,
        },
      },
      { 'filetype', icon_only = true, separator = '', padding = { left = 1, right = 0 } },
      { path.pretty_path },
      {
        symbols.get,
        cond = function()
          return vim.g.trouble_lualine and vim.b.trouble_lualine ~= false and symbols.has()
        end,
      },
    },
    lualine_x = {
      snacks.profiler.status(),
      {
        function()
          return require('noice').api.status.command.get()
        end,
        cond = function()
          return require('noice').api.status.command.has()
        end,
        color = function()
          return { fg = snacks.util.color 'Statement' }
        end,
      },
      {
        function()
          return require('noice').api.status.mode.get()
        end,
        cond = function()
          return require('noice').api.status.mode.has()
        end,
        color = function()
          return { fg = snacks.util.color 'Constant' }
        end,
      },
      {
        'diff',
        symbols = { added = icons.git.added, modified = icons.git.modified, removed = icons.git.removed },
        source = function()
          local status = vim.b.gitsigns_status_dict
          if status then
            return { added = status.added, modified = status.changed, removed = status.removed }
          end
        end,
      },
    },
    lualine_y = {
      { 'progress', separator = ' ', padding = { left = 1, right = 0 } },
      { 'location', padding = { left = 0, right = 1 } },
    },
    lualine_z = {
      function()
        return ' ' .. os.date '%R'
      end,
    },
  },
  extensions = { 'fzf' },
}
