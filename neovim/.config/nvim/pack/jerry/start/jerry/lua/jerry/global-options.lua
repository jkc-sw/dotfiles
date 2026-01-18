-- Set <Space> as leader
vim.g.mapleader = " "

-- Native settings
-- vim.cmd("filetype plugin on")
-- vim.cmd("syntax on") -- Disabled as per your comment
-- vim.o.completeopt = "menuone,noinsert,noselect"
-- vim.o.number = true
-- vim.o.relativenumber = true
vim.g.loaded_clipboard_provider = 1
vim.g.netrw_banner = 0
vim.g.netrw_browse_split = 4
vim.g.netrw_winsize = 25
vim.g.vimsyn_embed = "l"
vim.o.autoindent = true
vim.o.background = "dark"
vim.o.backup = false
vim.o.cmdheight = 1
vim.o.cursorline = true
vim.o.errorbells = false
vim.o.expandtab = true
vim.o.fixendofline = false
vim.o.foldenable = false
vim.o.grepprg = "rg --line-number --color=never"
vim.o.guicursor = "i-ci-ve:block-blinkwait175-blinkoff150-blinkon175"
vim.o.hidden = true
vim.o.hlsearch = false
vim.o.ignorecase = true
vim.o.inccommand = "split"
vim.o.incsearch = true
vim.o.list = true
vim.opt.laststatus = 3 -- Recommended by avante.nvim
vim.o.mouse = "nv"
vim.o.regexpengine = 1
vim.o.scrolloff = 5
vim.o.shiftround = true
vim.o.shiftwidth = 4
vim.o.shortmess = vim.o.shortmess .. "c"
vim.o.showmode = false
vim.o.signcolumn = "no"
vim.o.smartcase = true
vim.o.smartindent = true
vim.o.softtabstop = 4
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.swapfile = false
vim.o.tabstop = 4
vim.o.termguicolors = true
vim.o.undodir = vim.fn.expand("~/.vim/undodir")
vim.o.undofile = true
vim.o.updatetime = 50
vim.o.wildmenu = true
vim.o.wrap = false
vim.opt.clipboard:append("unnamed")
vim.opt.diffopt:append("iwhiteeol")
vim.opt.path:append("**")

vim.g.gruvbox_material_background = "hard"
vim.g.gruvbox_material_foreground = "material"
vim.g.gruvbox_material_better_performance = 0
vim.cmd("colorscheme gruvbox-material")

vim.g.rg_derive_root = true
vim.g.use_fzf = 0

-- Keymaps
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map("n", "<leader>h", "<cmd>wincmd h<CR>", opts)
map("n", "<leader>j", "<cmd>wincmd j<CR>", opts)
map("n", "<leader>k", "<cmd>wincmd k<CR>", opts)
map("n", "<leader>l", "<cmd>wincmd l<CR>", opts)
map("n", "<leader>U", "<cmd>UndotreeShow<CR>", opts)
map("n", "<leader>pv", "<cmd>vertical topleft wincmd v | Ex | vertical resize 50<CR>", opts)
map("n", "<leader>pp", "<cmd>call jerry#common#TogglePasteMode()<CR>", opts)
map("n", "<leader>r", "<cmd>silent exec '!tswitch -c nv'<CR>", opts)
map("n", "<leader>,.", "<cmd>call execute(getline('.'), '')<CR>", opts)
map("v", "<leader>,.", ":<C-u>lua require('jerry.sourcer').eval_vimscript(table.concat(vim.fn['jerry#common#GetVisualSelectionAsList'](), '\\n'))<CR>", opts)
map("n", "<leader>,p", "<cmd>call luaeval(getline('.'), '')<CR>", opts)
map("v", "<leader>,p", ":<C-u>lua require('jerry.sourcer').eval_lua(table.concat(vim.fn['jerry#common#GetVisualSelectionAsList'](), '\\n'))<CR>", opts)
map("n", "<leader>T", "<cmd>lua SL()<CR>", opts)
map("v", "<leader>T", ":<C-u>lua SV()<CR>", opts)

map("n", "<leader>oe", "<cmd>silent execute \"!tmux send-keys -t :.+1 Up Enter\"<CR>", opts)
map("n", "<leader>ou", "<cmd>silent execute \"!tmux send-keys -t :.-1 Up Enter\"<CR>", opts)
map("n", "<leader>oa", "<cmd>silent execute \"!tmux send-keys -t :-.1 Up Enter\"<CR>", opts)
map("n", "<leader>oo", "<cmd>silent execute \"!tmux send-keys -t :+.1 Up Enter\"<CR>", opts)

map("n", "<leader>ty", "<cmd>lua require('jerry.sourcer').lua_sourcer('SOURCE_THESE_LUAS_START', 'SOURCE_THESE_LUAS_END')<CR>", opts)
map("n", "<leader>ti", "<cmd>lua require('jerry.sourcer').vim_sourcer('SOURCE_THESE_VIMS_START', 'SOURCE_THESE_VIMS_END')<CR>", opts)
map("n", "<leader>tp", "<cmd>lua require('jerry.marker').mark_these('MARK_THIS_PLACE')<CR>", opts)

map("n", "<C-p>", "<cmd>call jerry#common#FileFuzzySearch()<CR>", opts)
map("n", "<leader>po", "<cmd>lua require('telescope.builtin').oldfiles()<CR>", opts)
map("n", "<leader>/", "<cmd>call jerry#common#LinesFuzzySearch()<CR>", opts)
map("n", "<leader>b", "<cmd>call jerry#common#BufferFuzzySearch()<CR>", opts)
map("n", "Q", "<cmd>call jerry#common#WordFuzzySearch()<CR>", opts)
map("n", "<leader>ps", "<cmd>call jerry#common#GlobalFuzzySearch()<CR>", opts)
map("n", "<leader>qf", "<cmd>lua require('telescope.builtin').quickfix()<CR>", opts)
map("n", "<leader>pa", "<cmd>call jerry#common#CloseTab()<CR>", opts)

map("n", "<leader><C-]>", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
map("n", "<leader>gd", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
map("n", "<leader>gf", "<cmd>lua vim.lsp.buf.format()<CR>", opts)
map("v", "<leader>gf", "<cmd>'<,'>lua vim.lsp.buf.format()<CR>", opts)
map("n", "<leader>gD", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
map("n", "<leader>gr", "<cmd>lua require('telescope.builtin').lsp_references()<CR>", opts)
map("n", "<leader>gR", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
map("n", "<leader>1gD", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
map("n", "<leader>ga", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
map("v", "<leader>ga", "<cmd>'<,'>lua vim.lsp.buf.range_code_action()<CR>", opts)
map("n", "<leader>K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
map("n", "<leader>go", "<cmd>call jerry#common#ListSymbols()<CR>", opts)
map("i", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)

map("n", "<leader>gO", "<cmd>lua vim.diagnostic.set_loclist()<CR>", opts)
map("n", "<leader>gs", "<cmd>LspInfo<CR>", opts)
map("n", "<leader>gg", "<cmd>lua vim.lsp.stop_client(vim.lsp.get_clients())<CR>", opts)
map("n", "<leader>gn", "<cmd>lua vim.diagnostic.goto_next { wrap = false, severity = 'Error' }<CR>", opts)
map("n", "<leader>gp", "<cmd>lua vim.diagnostic.goto_prev { wrap = false, severity = 'Error' }<CR>", opts)
map("n", "<leader>gN", "<cmd>lua vim.diagnostic.goto_next { wrap = false, severity_limit = 'Warning' }<CR>", opts)
map("n", "<leader>gP", "<cmd>lua vim.diagnostic.goto_prev { wrap = false, severity_limit = 'Warning' }<CR>", opts)

map("n", "<leader>Hl", "<cmd>so $VIMRUNTIME/syntax/hitest.vim<CR>", opts)
map("n", "<leader>Hh", function()
    local synID = vim.fn.synID
    local synIDattr = vim.fn.synIDattr
    local synIDtrans = vim.fn.synIDtrans
    local line = vim.fn.line(".")
    local col = vim.fn.col(".")
    print("hi<" .. synIDattr(synID(line, col, 1), "name") ..
        "> trans<" .. synIDattr(synID(line, col, 0), "name") ..
        "> lo<" .. synIDattr(synIDtrans(synID(line, col, 1)), "name") .. ">")
end, opts)

map("v", "<leader>p", "\"0p", opts)
map("n", "<leader>fm", "vip:g/\\|/Tab/\\|/<CR>", opts)
map("n", "]c", "]czz", opts)
map("n", "[c", "[czz", opts)
map("n", "n", "nzz", opts)
map("n", "N", "Nzz", opts)
map("i", "<C-c>", "<ESC>", opts)
map("n", ";", ":", opts)
map("n", ":", ";", opts)
map("v", ";", ":", opts)
map("v", ":", ";", opts)

-- let g:clip_supplier = ['toclip']
vim.g.clip_supplier = { "toclip" }

vim.filetype.add({
  extensions = {
    inc = 'bitbake',
    keymap = 'keymap',
  }
})

vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    pcall(vim.treesitter.start)
  end,
})
