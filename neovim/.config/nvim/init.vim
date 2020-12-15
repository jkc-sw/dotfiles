" Native settings
syntax on
filetype plugin on

let mapleader = " "
set hidden
set nohlsearch
set path+=**
set clipboard+=unnamedplus
set noerrorbells
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set autoindent
set mouse=nvic
set number relativenumber
set nowrap
set smartcase
set ignorecase
set noswapfile
set nobackup
set undodir=~/.vim/undodir
set undofile
set incsearch
set wildmenu
set cmdheight=1
set updatetime=50
set shortmess+=c
set colorcolumn=80
set noshowmode
set background=dark
set splitbelow splitright
set termguicolors
set guicursor=i-ci-ve:block-blinkwait175-blinkoff150-blinkon175
set completeopt=menuone,noinsert,noselect
set signcolumn=yes
highlight ColorColumn ctermbg=0 guibg=lightgrey
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 25
set nofoldenable
set scrolloff=15 " Make sure that cursor won't be too high
set cursorline

" Plugin manager section
"   Install this plugin manager from https://github.com/junegunn/vim-plug
call plug#begin('~/.vim/plugged')
Plug 'gruvbox-community/gruvbox'
Plug 'vim-utils/vim-man'
Plug 'mbbill/undotree'
Plug 'tomtom/tcomment_vim'
Plug 'tpope/vim-surround'
Plug 'sainnhe/gruvbox-material'
Plug 'flazz/vim-colorschemes'
Plug 'michaeljsmith/vim-indent-object'
Plug 'itchyny/lightline.vim'
Plug 'pprovost/vim-ps1'
Plug 'kergoth/vim-bitbake'
Plug 'godlygeek/tabular'
Plug 'sheerun/vim-polyglot'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/completion-nvim'
Plug 'tjdevries/nlua.nvim'
Plug 'tjdevries/lsp_extensions.nvim'
Plug 'tpope/vim-fugitive'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-lua/telescope.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/playground'
Plug 'romgrk/nvim-treesitter-context'
call plug#end()

" if define headless update
if $ANSIBLE_UPDATE
    :PlugInstall
    :PlugUpdate
    :PlugClean!
    finish
endif

" Color setting
if exists('+termguicolors')
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif
let g:gruvbox_contrast_dark = 'hard'
let g:gruvbox_invert_selections = '0'
colorscheme gruvbox
" colorscheme ayu

" Treesitter install
augroup treesitterInstall
    autocmd!
    autocmd VimEnter * TSInstall maintained
augroup END

" lsp setup
let g:completion_matching_strategy_list = ['exact', 'substring', 'fuzzy']
augroup nowhitespaceattheend
    autocmd!
    autocmd BufEnter * lua require'completion'.on_attach()
augroup END
" configure my lsp setup
lua require'my_lsp_setup'.setup_lsp()
lua require'my_lsp_setup'.install_lsp{}

" Treesitter setup
lua << EOF
require'nvim-treesitter.configs'.setup{
    highlight = { enable = true },
    indent = { enable = true }
}
EOF

" Straight from the lsp help page
function! LspStatus()
    return luaeval("require'my_lsp_setup'.construct_statusline{}")
endfunction

" The lightline configuration
let g:lightline = {
    \ 'colorscheme': 'seoul256',
    \ 'active': {
    \   'left': [['mode', 'paste'], ['gitbranch', 'readonly', 'filename', 'modified']],
    \   'right': [['lineinfo', 'lsp'], ['percent'], ['fileformat', 'fileencoding', 'filetype']]
    \ },
    \ 'inactive': {
    \   'left': [['filename']],
    \   'right': [['lineinfo'], ['percent']]
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
    \   'lsp': 'LspStatus',
    \   'gitbranch': 'FugitiveStatusline'
    \ },
    \ }

" Configure the sorter
lua require('telescope').setup({defaults = {file_sorter = require('telescope.sorters').get_fzy_sorter}})

" Whether if I want to use fzf or telescope
let g:rg_derive_root='true'
let g:use_fzf = 0

" function to search through files
func! FileFuzzySearch()
    if g:use_fzf
        :Files
    else
        lua require'telescope.builtin'.find_files{find_command = vim.split(vim.env.FZF_DEFAULT_COMMAND, ' ')}
    endif
endfun

" function to search through buffer
func! BufferFuzzySearch()
    if g:use_fzf
        :Buffers
    else
        lua require'telescope.builtin'.buffers{}
    endif
endfun

" rg function to use later
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg -- '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview(), <bang>0)

" function to search string globally
func! WordFuzzySearch()
    if g:use_fzf
        exec ':Rg '.expand('<cword>')
    else
        lua require('telescope.builtin').grep_string()
    endif
endfun

" function to find references
func! ListSymbols()
    if g:use_fzf
        echom "List symbols from fzf is not supported"
    else
        lua require('telescope.builtin').lsp_document_symbols()
    endif
endfun

" function to search string globally for a string
func! GlobalFuzzySearch()
    if g:use_fzf
        let word = input('Grep For >')
        exec ':Rg '.word
    else
        lua require('telescope.builtin').grep_string({ search = vim.fn.input("Grep For >") })
    endif
endfun

" Keyboard remap
nnoremap <leader>h     <cmd> wincmd h<CR>
nnoremap <leader>j     <cmd> wincmd j<CR>
nnoremap <leader>k     <cmd> wincmd k<CR>
nnoremap <leader>l     <cmd> wincmd l<CR>
nnoremap <leader>u     <cmd> UndotreeShow<CR>
nnoremap <leader>pv    <cmd> vertical topleft wincmd v<bar> :Ex <bar> :vertical resize 30<CR>
nnoremap <leader>V     <cmd> vsp ~/.config/nvim/init.vim<CR>
nnoremap <leader>w     <cmd> w<CR>
nnoremap <c-p>         <cmd> call FileFuzzySearch()<CR>
nnoremap <leader>b     <cmd> call BufferFuzzySearch()<CR>
nnoremap <leader>o     <cmd> call ListSymbols()<CR>
nnoremap Q             <cmd> call WordFuzzySearch()<CR>
nnoremap <leader>ps    <cmd> call GlobalFuzzySearch()<CR>
nnoremap <leader><c-]> <cmd> lua vim.lsp.buf.definition()<CR>
nnoremap <leader>K     <cmd> lua vim.lsp.buf.hover()<CR>
nnoremap <leader>gD    <cmd> lua vim.lsp.buf.implementation()<CR>
nnoremap <leader><c-k> <cmd> lua vim.lsp.buf.signature_help()<CR>
nnoremap <leader>1gD   <cmd> lua vim.lsp.buf.type_definition()<CR>
nnoremap <leader>gr    <cmd> lua vim.lsp.buf.references()<CR>
nnoremap <leader>g0    <cmd> lua vim.lsp.buf.document_symbol()<CR>
nnoremap <leader>gW    <cmd> lua vim.lsp.buf.workspace_symbol()<CR>
nnoremap <leader>gd    <cmd> lua vim.lsp.buf.declaration()<CR>
nnoremap <leader>go    <cmd> lua vim.lsp.diagnostic.set_loclist() <CR>
nnoremap <leader>gn    <cmd> lua vim.lsp.diagnostic.goto_next { wrap = false, severity = 'Error' }<CR>
nnoremap <leader>gp    <cmd> lua vim.lsp.diagnostic.goto_prev { wrap = false, severity = 'Error' }<CR>
nnoremap <leader>gN    <cmd> lua vim.lsp.diagnostic.goto_next { wrap = false, severity_limit = 'Warning' }<CR>
nnoremap <leader>gP    <cmd> lua vim.lsp.diagnostic.goto_prev { wrap = false, severity_limit = 'Warning' }<CR>
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
nnoremap ]c ]czz
nnoremap [c [czz
inoremap <C-c> <ESC>

" " Unused items, but sad to delete them
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

" Trim the whitespaces
fun! TrimWhitespace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfun
augroup nowhitespaceattheend
    autocmd!
    autocmd BufWritePre * :call TrimWhitespace()
augroup END
