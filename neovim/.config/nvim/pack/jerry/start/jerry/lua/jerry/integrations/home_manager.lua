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

-- Yanks are piped to an external clipboard tool instead of Neovim's
-- clipboard provider.
local function setup_clipboard()
  vim.g.loaded_clipboard_provider = 1
  vim.g.clip_supplier = { 'toclip' }

  if vim.fn.executable(vim.g.clip_supplier[1]) ~= 1 then
    vim.api.nvim_echo({
      { 'No clipboard tool found. Need to be toclip, win32yank.exe or clip.exe', 'WarningMsg' },
    }, false, {})
    return
  end

  vim.api.nvim_create_autocmd('TextYankPost', {
    group = vim.api.nvim_create_augroup('toClipBoard', { clear = true }),
    pattern = '*',
    callback = function()
      local event = vim.v.event
      if event.operator == 'y' and event.regname == '' then
        local ret = vim.fn.system(vim.g.clip_supplier, vim.fn.getreg('"'))
        if vim.g.toclip_verbose then
          vim.api.nvim_echo({
            { table.concat(vim.g.clip_supplier, ' ') .. ' (' .. vim.v.shell_error .. '): ' .. ret },
          }, false, {})
        end
      end
    end,
  })
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
  setup_clipboard()
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
