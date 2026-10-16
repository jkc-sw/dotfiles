local config = vim.fn.stdpath 'config'
local state = vim.fn.stdpath 'state'
vim.fn.mkdir(state, 'p')

-- Home Manager deploys a read-only configuration. Keep native manager state
-- writable, seeding new installations with the revisions/extras tracked here.
local function seed(name)
  local target = state .. '/' .. name
  local source = config .. '/' .. name
  if not vim.uv.fs_stat(target) and vim.uv.fs_stat(source) then
    vim.fn.writefile(vim.fn.readfile(source), target)
  end
  return target
end
local lockfile = seed 'lazy-lock.json'
vim.g.lazyvim_json = seed 'lazyvim.json'

-- Machine-local options/plugin specs belong outside the managed directory.
-- Use <state>/local/lua/config/local.lua or <state>/local/lua/plugins/local.lua.
local local_config = state .. '/local'
if vim.uv.fs_stat(local_config) then
  vim.opt.rtp:prepend(local_config)
end

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    'https://github.com/folke/lazy.nvim.git',
    lazypath,
  }
  if vim.v.shell_error ~= 0 then
    error('Failed to bootstrap lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup {
  lockfile = lockfile,
  spec = {
    { 'LazyVim/LazyVim', import = 'lazyvim.plugins' },
    -- Extras are tracked here: :LazyExtras only writes the state copy of lazyvim.json.
    { import = 'lazyvim.plugins.extras.coding.mini-surround' },
    { import = 'lazyvim.plugins.extras.formatting.prettier' },
    { import = 'lazyvim.plugins.extras.lang.clangd' },
    { import = 'lazyvim.plugins.extras.lang.cmake' },
    { import = 'lazyvim.plugins.extras.lang.docker' },
    { import = 'lazyvim.plugins.extras.lang.go' },
    { import = 'lazyvim.plugins.extras.lang.java' },
    { import = 'lazyvim.plugins.extras.lang.json' },
    { import = 'lazyvim.plugins.extras.lang.markdown' },
    { import = 'lazyvim.plugins.extras.lang.nix' },
    { import = 'lazyvim.plugins.extras.lang.python' },
    { import = 'lazyvim.plugins.extras.lang.rust' },
    { import = 'lazyvim.plugins.extras.lang.tex' },
    { import = 'lazyvim.plugins.extras.lang.typescript' },
    { import = 'lazyvim.plugins.extras.lang.yaml' },
    { import = 'plugins' },
    {
      import = 'plugins.local',
      cond = function()
        return vim.uv.fs_stat(local_config .. '/lua/plugins/local.lua') ~= nil
      end,
    },
  },
  defaults = { lazy = false, version = false },
  install = { colorscheme = { 'gruvbox-material', 'habamax' } },
  checker = { enabled = true, notify = false },
  performance = {
    rtp = { paths = { local_config }, disabled_plugins = { 'gzip', 'tarPlugin', 'tohtml', 'tutor', 'zipPlugin' } },
  },
}
