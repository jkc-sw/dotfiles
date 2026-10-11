local M = {}
local configured = false

-- The distribution owns editor defaults and third-party plugins. This plugin
-- only registers custom tools, runtime files and filetype support.
function M.setup()
  if configured then
    return M
  end
  vim.g.jerry_enabled = true
  vim.filetype.add { extensions = { inc = 'bitbake', keymap = 'keymap' } }
  require 'jerry.global-autocommands'
  require 'jerry.global-funcs'
  require('jerry.tmux').setup()
  require('jerry.lua-tools').setup()
  require('jerry.clipboard').setup()
  configured = true
  return M
end

return M
