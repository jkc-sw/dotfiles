-- Set <Space> as leader
vim.g.mapleader = ' '

-- Native settings
-- vim.cmd("filetype plugin on")
-- vim.cmd("syntax on") -- Disabled as per your comment
-- vim.o.completeopt = "menuone,noinsert,noselect"
-- vim.o.number = true
-- vim.o.relativenumber = true
vim.g.netrw_banner = 0
vim.g.netrw_browse_split = 4
vim.g.netrw_winsize = 25
vim.g.vimsyn_embed = 'l'
vim.o.autoindent = true
vim.o.background = 'dark'
vim.o.backup = false
vim.o.cmdheight = 1
vim.o.cursorline = true
vim.o.errorbells = false
vim.o.expandtab = true
vim.o.fixendofline = false
vim.o.foldenable = false
vim.o.grepprg = 'rg --line-number --color=never'
vim.o.guicursor = 'i-ci-ve:block-blinkwait175-blinkoff150-blinkon175'
vim.o.hidden = true
vim.o.hlsearch = false
vim.o.ignorecase = true
vim.o.inccommand = 'split'
vim.o.incsearch = true
vim.o.list = true
vim.opt.laststatus = 3 -- Recommended by avante.nvim
vim.o.mouse = 'nv'
vim.o.regexpengine = 1
vim.o.scrolloff = 5
vim.o.shiftround = true
vim.o.shiftwidth = 4
vim.o.shortmess = vim.o.shortmess .. 'c'
vim.o.showmode = false
vim.o.signcolumn = 'no'
vim.o.smartcase = true
vim.o.smartindent = true
vim.o.softtabstop = 4
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.swapfile = false
vim.o.tabstop = 4
vim.o.termguicolors = true
vim.o.undodir = vim.fn.expand '~/.vim/undodir'
vim.o.undofile = true
vim.o.updatetime = 50
vim.o.wildmenu = true
vim.o.wrap = false
vim.opt.clipboard:append 'unnamed'
vim.opt.diffopt:append 'iwhiteeol'
vim.opt.path:append '**'

vim.g.rg_derive_root = true
vim.g.use_fzf = 0

-- Shared mappings only cover actions without a LazyVim default shortcut.
-- Each integrator owns navigation, search, LSP, diagnostics, and tab controls.
local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
end

map('n', '<leader>pp', '<cmd>call jerry#common#TogglePasteMode()<CR>', 'Toggle paste mode')
map('n', '<leader>r', "<cmd>silent exec '!tswitch -c nv'<CR>", 'Switch tmux session')
map('n', '<leader>,.', "<cmd>call execute(getline('.'), '')<CR>", 'Evaluate Vimscript line')
map(
  'v',
  '<leader>,.',
  ":<C-u>lua require('jerry.sourcer').eval_vimscript"
    .. "(table.concat(vim.fn['jerry#common#GetVisualSelectionAsList'](), '\\n'))<CR>",
  'Evaluate Vimscript selection'
)
map('n', '<leader>,p', "<cmd>call luaeval(getline('.'), '')<CR>", 'Evaluate Lua line')
map(
  'v',
  '<leader>,p',
  ":<C-u>lua require('jerry.sourcer').eval_lua"
    .. "(table.concat(vim.fn['jerry#common#GetVisualSelectionAsList'](), '\\n'))<CR>",
  'Evaluate Lua selection'
)
map('n', '<leader>T', '<cmd>lua SL()<CR>', 'Send line to Neovim terminal')
map('v', '<leader>T', ':<C-u>lua SV()<CR>', 'Send selection to Neovim terminal')

map('n', '<leader>oe', '<cmd>silent execute "!tmux send-keys -t :.+1 Up Enter"<CR>', 'Repeat command in next tmux pane')
map(
  'n',
  '<leader>ou',
  '<cmd>silent execute "!tmux send-keys -t :.-1 Up Enter"<CR>',
  'Repeat command in previous tmux pane'
)
map(
  'n',
  '<leader>oa',
  '<cmd>silent execute "!tmux send-keys -t :-.1 Up Enter"<CR>',
  'Repeat command in previous tmux window'
)
map(
  'n',
  '<leader>oo',
  '<cmd>silent execute "!tmux send-keys -t :+.1 Up Enter"<CR>',
  'Repeat command in next tmux window'
)

map(
  'n',
  '<leader>ty',
  "<cmd>lua require('jerry.sourcer').lua_sourcer('SOURCE_THESE_LUAS_START', 'SOURCE_THESE_LUAS_END')<CR>",
  'Source marked Lua block'
)
map(
  'n',
  '<leader>ti',
  "<cmd>lua require('jerry.sourcer').vim_sourcer('SOURCE_THESE_VIMS_START', 'SOURCE_THESE_VIMS_END')<CR>",
  'Source marked Vimscript block'
)
map('n', '<leader>tp', "<cmd>lua require('jerry.marker').mark_these('MARK_THIS_PLACE')<CR>", 'Mark text region')
map('n', '<leader>gQ', function()
  for _, client in ipairs(vim.lsp.get_clients()) do
    client:stop()
  end
end, 'Stop all LSP clients')

map('n', '<leader>Hl', '<cmd>so $VIMRUNTIME/syntax/hitest.vim<CR>', 'Show syntax highlight test')
map('v', '<leader>p', '"0p', 'Paste last yank (register 0)')
map('n', '<leader>fm', 'vip:g/\\|/Tab/\\|/<CR>', 'Align pipe-separated paragraph')

vim.filetype.add {
  extensions = {
    inc = 'bitbake',
    keymap = 'keymap',
  },
}
