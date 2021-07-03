" Plugin manager section
"   Install this plugin manager from https://github.com/junegunn/vim-plug
call plug#begin('~/.vim/plugged')
Plug 'gruvbox-community/gruvbox'
Plug 'vim-utils/vim-man'
Plug 'mbbill/undotree'
Plug 'tomtom/tcomment_vim'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'sainnhe/gruvbox-material'
Plug 'michaeljsmith/vim-indent-object'
Plug 'itchyny/lightline.vim'
Plug 'pprovost/vim-ps1'
Plug 'kergoth/vim-bitbake'
Plug 'godlygeek/tabular'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'neovim/nvim-lspconfig'
Plug 'glepnir/lspsaga.nvim'
Plug 'tjdevries/nlua.nvim'
Plug 'nvim-lua/lsp_extensions.nvim'
Plug 'tpope/vim-fugitive'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-lua/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/playground'
Plug 'romgrk/nvim-treesitter-context'
Plug 'haringsrob/nvim_context_vt'
Plug 'modille/groovy.vim'
Plug 'tjdevries/colorbuddy.vim'
Plug 'tjdevries/gruvbuddy.nvim'
Plug 'onsails/lspkind-nvim'
Plug 'hrsh7th/nvim-compe'
Plug 'dhruvasagar/vim-testify'
Plug 'arzg/vim-colors-xcode'

" Local
Plug $HOME.'/repos/focus-side.vim'
Plug $HOME.'/repos/vim-matlab.vim'

" Not working
" Plug 'sheerun/vim-polyglot'

" Not used
" Plug 'nvim-lua/completion-nvim'
" Plug 'navarasu/onedark.nvim'

" Maybe future
" Plug 'kyazdani42/nvim-tree.lua'

" Always the last
Plug 'ryanoasis/vim-devicons'
Plug 'kyazdani42/nvim-web-devicons'
call plug#end()

" if define headless update
if $ANSIBLE_UPDATE
    :PlugInstall
    :PlugUpdate
    :PlugClean!
    finish
endif

" Native settings
syntax on
filetype plugin on
let mapleader = " "
set hidden
set nohlsearch
set path+=**
set clipboard+=unnamed
set noerrorbells
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set autoindent
set mouse=nv
set number relativenumber
set nowrap
set smartcase
set ignorecase
set noswapfile
set nobackup
set undodir=~/.vim/undodir
set undofile
set incsearch
set inccommand=split
set wildmenu
set cmdheight=1
set updatetime=50
set shortmess+=c
set noshowmode
set background=dark
set splitbelow splitright
set termguicolors
set guicursor=i-ci-ve:block-blinkwait175-blinkoff150-blinkon175
set completeopt=menuone,noinsert,noselect
set signcolumn=yes
let g:netrw_banner = 0
let g:netrw_browse_split = 4
let g:netrw_winsize = 25
set nofoldenable
set scrolloff=15 " Make sure that cursor won't be too high
set cursorline
let g:vimsyn_embed = 'l'
let g:loaded_clipboard_provider = 1 " I don't need nvim to sync clipboard for me, I have my own tool
set grepprg=rg\ --line-number\ --color=never
set regexpengine=1
set redrawtime=15000

" Not used
" highlight ColorColumn ctermbg=0 guibg=lightgrey
" set colorcolumn=80

" " Color setting
" if exists('+termguicolors')
"     let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
"     let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
" endif
" let g:gruvbox_contrast_dark = 'hard'
" let g:gruvbox_invert_selections = '0'
" colorscheme gruvbox
" " colorscheme ayu

" " let g:onedark_style = 'darker'
" colorscheme onedark

colorscheme xcodedarkhc

" load everything lua
lua require('jerry')

" Not used
let g:completion_matching_strategy_list = ['exact', 'substring', 'fuzzy']

" The lightline configuration
let g:lightline = {
    \ 'colorscheme': 'jellybeans',
    \ 'active': {
    \   'left': [['mode', 'paste'], ['asyncjob', 'gitbranch', 'readonly', 'filename', 'modified']],
    \   'right': [['lineinfo', 'lsp'], ['percent'], ['fileformat', 'fileencoding', 'filetype']]
    \ },
    \ 'inactive': {
    \   'right': [[''], [''], ['shortpath']],
    \   'left': [['lineinfo'], ['percent']]
    \ },
    \ 'component': {
    \   'mode': '%{lightline#mode()}',
    \   'absolutepath': '%F', 'relativepath': '%f', 'filename': '%f', 'modified': '%M', 'bufnum': '%n',
    \   'paste': '%{&paste?"PASTE":""}', 'readonly': '%R', 'charvalue': '%b', 'charvaluehex': '%B',
    \   'spell': '%{&spell?&spelllang:""}', 'fileencoding': '%{&fenc!=#""?&fenc:&enc}', 'fileformat': '%{&ff}',
    \   'filetype': '%{&ft!=#""?&ft:"no ft"}', 'percent': '%3p%%', 'percentwin': '%P',
    \   'lineinfo': '%3l:%-2c', 'line': '%l', 'column': '%c', 'close': '%999X X ', 'winnr': '%{winnr()}'
    \ },
    \ 'component_function': {
    \   'asyncjob': 'jerry#common#AsyncJobReport',
    \   'lsp': 'jerry#common#LspStatus',
    \   'gitbranch': 'FugitiveStatusline',
    \   'shortpath': 'jerry#common#CorrentFileShortener'
    \ },
    \ }

" Whether if I want to use fzf or telescope
let g:rg_derive_root='true'
let g:use_fzf = 0

" rg function to use later
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg -- '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview(), <bang>0)

" Key map
nnoremap <leader>h     <cmd>  wincmd h<CR>
nnoremap <leader>j     <cmd>  wincmd j<CR>
nnoremap <leader>k     <cmd>  wincmd k<CR>
nnoremap <leader>l     <cmd>  wincmd l<CR>
nnoremap <leader>u     <cmd>  UndotreeShow<CR>
nnoremap <leader>pv    <cmd>  vertical topleft wincmd v<bar> Ex <bar> vertical resize 50<CR>
nnoremap <leader>pp    <cmd>  call jerry#common#TogglePasteMode()<CR>
nnoremap <leader>v     <cmd>  vertical botright split ~/repos/dotfiles/neovim/.config/nvim/init.vim <CR>
nnoremap <leader>V     <cmd>  exec("lua require('jerry.telescope.pickers').find_dotfiles{}") <bar> lcd ~/repos/dotfiles <CR>
nnoremap <leader>r     <cmd>  FS<CR>
nnoremap <leader>cc    <cmd>  FSOffset -3<CR>
nnoremap <leader>E     <cmd>  exec getline('.')<cr>
vnoremap <leader>E     :<c-u> exec join(filter(getline("'<", "'>"), 'v:val !~ "^\".*"'), '<bar>')<cr>
nnoremap <leader>T     <cmd>  lua SL()<cr>
vnoremap <leader>T     :<c-u> lua SV()<cr>

nnoremap <c-p>         <cmd>  call jerry#common#FileFuzzySearch()<CR>
nnoremap <leader>/     <cmd>  call jerry#common#LinesFuzzySearch()<CR>
nnoremap <leader>b     <cmd>  call jerry#common#BufferFuzzySearch()<CR>
nnoremap <leader>o     <cmd>  call jerry#common#ListSymbols()<CR>
nnoremap Q             <cmd>  call jerry#common#WordFuzzySearch()<CR>
nnoremap <leader>ps    <cmd>  call jerry#common#GlobalFuzzySearch()<CR>
nnoremap <leader>q     <cmd>  lua require('telescope.builtin').quickfix()<CR>

nnoremap <leader><c-]> <cmd>  lua vim.lsp.buf.definition()<CR>
nnoremap <leader>gd    <cmd>  lua vim.lsp.buf.declaration()<CR>
nnoremap <leader>gf    <cmd>  lua vim.lsp.buf.formatting()<CR>
vnoremap <leader>gF    <cmd>  '<,'>lua vim.lsp.buf.range_formatting()<CR>
nnoremap <leader>gD    <cmd>  lua vim.lsp.buf.implementation()<CR>
nnoremap <leader>gr    <cmd>  lua require('telescope.builtin').lsp_references()<CR>
nnoremap <leader>gR    <cmd>  lua require('lspsaga.rename').rename()<CR>
nnoremap <leader>1gD   <cmd>  lua vim.lsp.buf.type_definition()<CR>
nnoremap <leader>ga    <cmd>  lua require('lspsaga.codeaction').code_action()<CR>
vnoremap <leader>ga    <cmd>  '<,'>lua require('lspsaga.codeaction').range_code_action()<CR>
nnoremap <leader>K     <cmd>  lua vim.lsp.buf.hover()<CR>

nnoremap <leader>go    <cmd>  lua vim.lsp.diagnostic.set_loclist() <CR>
nnoremap <leader>gs    <cmd>  lua print(vim.inspect(vim.lsp.get_active_clients())) <CR>
nnoremap <leader>gg    <cmd>  lua vim.lsp.stop_client(vim.lsp.get_active_clients())<CR>
nnoremap <leader>gn    <cmd>  lua vim.lsp.diagnostic.goto_next { wrap = false, severity = 'Error' }<CR>
nnoremap <leader>gp    <cmd>  lua vim.lsp.diagnostic.goto_prev { wrap = false, severity = 'Error' }<CR>
nnoremap <leader>gN    <cmd>  lua vim.lsp.diagnostic.goto_next { wrap = false, severity_limit = 'Warning' }<CR>
nnoremap <leader>gP    <cmd>  lua vim.lsp.diagnostic.goto_prev { wrap = false, severity_limit = 'Warning' }<CR>

vnoremap <leader>p "_dP
nnoremap <leader>tm vip:Tab/\|/<cr>
nnoremap ]c ]czz
nnoremap [c [czz
inoremap <C-c> <ESC>
nnoremap ; :
nnoremap : ;
vnoremap ; :
vnoremap : ;

" TODO remove after some testing
" nnoremap <leader><c-]> <cmd> lua require('lspsaga.provider').lsp_finder()<CR>
" nnoremap <leader>1gD   <cmd> lua require('lspsaga.provider').lsp_finder()<CR>
" nnoremap <leader>gr    <cmd> lua vim.lsp.buf.references()<CR>
" nnoremap <leader>gr     <cmd> lua require('lspsaga.provider').lsp_finder()<CR>
" nnoremap <leader>g<c-]> <cmd> lua require'lspsaga.provider'.preview_definition()<CR>
" nnoremap <leader>K      <cmd> lua require('lspsaga.hover').render_hover_doc()<CR>
" nnoremap <leader>gk     <cmd> lua require('lspsaga.signaturehelp').signature_help()<CR>

" Takes too long for big project
" nnoremap <leader>gW    <cmd> lua require'telescope.builtin'.lsp_workspace_symbols{}<CR>

" " Unused items, but sad to delete them
" vnoremap J :m '>+1<CR>gv=gv
" vnoremap K :m '<-2<CR>gv=gv
" nnoremap <silent> <Leader>+ :vertical resize +5<CR>
" nnoremap <silent> <Leader>- :vertical resize -5<CR>

" Use toclip to send content to clipboard
augroup toClipBoard
    autocmd!
    autocmd TextYankPost * if v:event.operator ==# 'y' && v:event.regname == ''
        \|     let ret = system('toclip', getreg('"'))
        \| endif
        " \|     echom ret
        " \| if empty($TMUX)
        " \| endif
augroup END

augroup inlayHint
    autocmd!
    autocmd BufEnter,BufWinEnter,TabEnter *.rs :lua require'lsp_extensions'.inlay_hints{}
augroup END

augroup nowhitespaceattheend
    autocmd!
    autocmd BufWritePre * :call jerry#common#TrimWhitespace()
augroup END

augroup matlabFileDetection
    autocmd!
    autocmd BufRead,BufNewFile *.m set filetype=matlab
augroup END

augroup LuaHighlight
    autocmd!
    autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank()
augroup END

augroup DisableSomeSyntax
    autocmd!
    autocmd BufEnter,BufWinEnter,TabEnter *.groovy,*.html syntax off
augroup END

