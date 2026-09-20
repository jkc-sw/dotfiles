local M = {}

local plugin_configs = {
  'jerry.plugins-cfg.lualine',
  'jerry.plugins-cfg.colorful-menu',
  'jerry.plugins-cfg.blink-cmp',
  'jerry.plugins-cfg.neogit',
  'jerry.plugins-cfg.lspkind',
  'jerry.plugins-cfg.nvim-treesitter',
  'jerry.plugins-cfg.nvim_context_vt',
  'jerry.plugins-cfg.telescope',
  'jerry.plugins-cfg.colorizer',
  'jerry.plugins-cfg.render-markdown',
}

local function add_user_config_to_packpath()
  local user_config = vim.uv.os_homedir() .. '/.config/nvim'
  if vim.uv.fs_stat(user_config) then
    vim.opt.packpath:prepend(user_config)
  end
end

local function setup_colorscheme()
  vim.g.gruvbox_material_background = 'hard'
  vim.g.gruvbox_material_foreground = 'material'
  vim.g.gruvbox_material_better_performance = 0
  vim.cmd.colorscheme('gruvbox-material')
end

local function setup_treesitter()
  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('jerry_home_manager_treesitter', { clear = true }),
    callback = function()
      pcall(function()
        vim.treesitter.start()
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end)
    end,
  })
end

function M.setup()
  setup_colorscheme()

  require('jerry.plugins-cfg.lazydev')
  require('jerry.lsp.config').setup()

  add_user_config_to_packpath()

  for _, module in ipairs(plugin_configs) do
    require(module)
  end

  setup_treesitter()
end

return M
