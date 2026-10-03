local M = {}

local configured = {
  custom = false,
  home_manager = false,
}

local defaults = {
  features = {
    home_manager = false,
    legacy = false,
  },
}

local function setup_custom_config(legacy)
  if configured.custom then
    return
  end

  -- Runtime files shipped by this plugin use this flag to avoid activating
  -- merely because the plugin is present on runtimepath.
  vim.g.jerry_enabled = true

  vim.filetype.add({ extensions = { inc = "bitbake", keymap = "keymap" } })
  vim.g.jerry_legacy = legacy
  if legacy then
    require('jerry.global-options')
    require('jerry.lua-tools').setup()
  else
    require('jerry.custom-keymaps').setup()
  end
  require('jerry.global-autocommands').setup({ legacy = legacy })
  require('jerry.global-commands')
  require('jerry.global-funcs')
  require('jerry.tmux').setup()

  configured.custom = true
end

---Configure the custom Neovim layer.
---
---Third-party plugin and LSP configuration is intentionally opt-in so that a
---distribution such as LazyVim can own those integrations.
---@param opts? { features?: { home_manager?: boolean, legacy?: boolean } }
function M.setup(opts)
  opts = vim.tbl_deep_extend('force', defaults, opts or {})

  setup_custom_config(opts.features.home_manager or opts.features.legacy)

  if opts.features.home_manager and not configured.home_manager then
    require('jerry.integrations.home_manager').setup()
    configured.home_manager = true
  end

  return M
end

return M
