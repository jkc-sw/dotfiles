local M = {}

local configured = {
  custom = false,
  home_manager = false,
}

local defaults = {
  features = {
    home_manager = false,
  },
}

local function setup_custom_config()
  if configured.custom then
    return
  end

  -- Runtime files shipped by this plugin use this flag to avoid activating
  -- merely because the plugin is present on runtimepath.
  vim.g.jerry_enabled = true

  require('jerry.global-options')
  require('jerry.global-autocommands')
  require('jerry.global-funcs')
  require('jerry.tmux').setup()
  require('jerry.lua-tools').setup()

  configured.custom = true
end

---Configure the custom Neovim layer.
---
---Third-party plugin and LSP configuration is intentionally opt-in so that a
---distribution such as LazyVim can own those integrations.
---@param opts? { features?: { home_manager?: boolean } }
function M.setup(opts)
  opts = vim.tbl_deep_extend('force', defaults, opts or {})

  setup_custom_config()

  if opts.features.home_manager and not configured.home_manager then
    require('jerry.integrations.home_manager').setup()
    configured.home_manager = true
  end

  return M
end

return M
