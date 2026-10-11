local M = {}

local plugin_configs = {
  'jerry.plugins-cfg.snacks',
  'jerry.plugins-cfg.noice',
  'jerry.plugins-cfg.editor',
  'jerry.plugins-cfg.conform',
  'jerry.plugins-cfg.lualine',
  'jerry.plugins-cfg.blink-cmp',
  'jerry.plugins-cfg.neogit',
  'jerry.plugins-cfg.nvim-treesitter',
  'jerry.plugins-cfg.telescope',
  'jerry.plugins-cfg.render-markdown',
}

local function setup_options()
  vim.g.maplocalleader = '\\'
  vim.g.have_nerd_font = true
  vim.g.autoformat = true
  vim.opt.number = true
  vim.opt.relativenumber = true
  vim.opt.signcolumn = 'yes'
  vim.opt.mouse = 'a'
  vim.opt.scrolloff = 4
  vim.opt.sidescrolloff = 8
  vim.opt.splitkeep = 'screen'
  vim.opt.timeoutlen = 300
  vim.opt.updatetime = 200
  vim.opt.tabstop = 2
  vim.opt.shiftwidth = 2
  vim.opt.softtabstop = 2
  -- Appearance and popup defaults from fresh LazyVim (TokyoNight Moon).
  vim.g.ai_cmp = true
  vim.g.snacks_animate = true
  vim.g.trouble_lualine = true
  vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
  vim.opt.conceallevel = 2
  vim.opt.cursorline = true
  vim.opt.fillchars = { foldopen = '', foldclose = '', fold = ' ', foldsep = ' ', diff = '╱', eob = ' ' }
  vim.opt.foldenable = true
  vim.opt.foldlevel = 99
  vim.opt.foldmethod = 'indent'
  vim.opt.foldtext = ''
  vim.opt.guicursor = vim.api.nvim_get_option_info2('guicursor', {}).default
  vim.opt.hlsearch = true
  vim.opt.inccommand = 'nosplit'
  vim.opt.laststatus = 3
  vim.opt.linebreak = true
  vim.opt.pumblend = 10
  vim.opt.pumheight = 10
  vim.opt.ruler = false
  vim.opt.shortmess:append { W = true, I = true, c = true, C = true }
  vim.opt.showmode = false
  vim.opt.smoothscroll = true
  vim.opt.virtualedit = 'block'
  vim.opt.wildmode = 'longest:full,full'
  vim.opt.winminwidth = 5
  vim.opt.undodir = vim.fn.stdpath 'state' .. '/undo'
  vim.fn.mkdir(vim.o.undodir, 'p')
end

local function add_user_config_to_packpath()
  local user_config = vim.uv.os_homedir() .. '/.config/nvim'
  if vim.uv.fs_stat(user_config) then
    vim.opt.packpath:prepend(user_config)
  end
end

local function setup_colorscheme()
  require('tokyonight').setup { style = 'moon' }
  require('tokyonight').load()
  require('catppuccin').setup {
    lsp_styles = {
      underlines = {
        errors = { 'undercurl' },
        hints = { 'undercurl' },
        warnings = { 'undercurl' },
        information = { 'undercurl' },
      },
    },
    integrations = {
      blink_cmp = true,
      flash = true,
      fzf = true,
      grug_far = true,
      gitsigns = true,
      lsp_trouble = true,
      mini = true,
      noice = true,
      snacks = true,
      telescope = true,
      which_key = true,
    },
  }
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
        local ret = vim.fn.system(vim.g.clip_supplier, vim.fn.getreg '"')
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
        if vim.treesitter.query.get(vim.treesitter.language.get_lang(vim.bo.filetype), 'folds') then
          vim.wo.foldmethod = 'expr'
          vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        end
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end)
    end,
  })
end

function M.setup()
  setup_options()
  setup_clipboard()
  require('mini.icons').setup {
    file = {
      ['.keep'] = { glyph = '󰊢', hl = 'MiniIconsGrey' },
      ['devcontainer.json'] = { glyph = '', hl = 'MiniIconsAzure' },
    },
    filetype = { dotenv = { glyph = '', hl = 'MiniIconsYellow' } },
  }
  require('mini.icons').mock_nvim_web_devicons()
  setup_colorscheme()

  require 'jerry.plugins-cfg.lazydev'

  add_user_config_to_packpath()

  for _, module in ipairs(plugin_configs) do
    require(module)
  end

  require('jerry.lsp.config').setup()
  setup_treesitter()
  require('jerry.integrations.home_manager.keymaps').setup()
end

return M
