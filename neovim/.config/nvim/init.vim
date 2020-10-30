" Native settings
syntax on
filetype plugin on

let mapleader = " "
set hidden
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
set completeopt=menuone,noinsert,noselect
set signcolumn=yes
highlight ColorColumn ctermbg=0 guibg=lightgrey
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 25
set nofoldenable

" Plugin manager section
"   Install this plugin manager from https://github.com/junegunn/vim-plug
call plug#begin('~/.vim/plugged')
Plug 'gruvbox-community/gruvbox'
Plug 'vim-utils/vim-man'
Plug 'mbbill/undotree'
Plug 'tomtom/tcomment_vim'
Plug 'tpope/vim-surround'
Plug 'michaeljsmith/vim-indent-object'
" Plug 'vim-airline/vim-airline'
" Plug 'vim-airline/vim-airline-themes'
Plug 'itchyny/lightline.vim'
Plug 'pprovost/vim-ps1'
Plug 'kergoth/vim-bitbake'
Plug 'godlygeek/tabular'
Plug 'sheerun/vim-polyglot'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/completion-nvim'
Plug 'nvim-lua/diagnostic-nvim'
Plug 'tjdevries/nlua.nvim'
Plug 'tjdevries/lsp_extensions.nvim'
Plug 'tpope/vim-fugitive'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-lua/telescope.nvim'
call plug#end()

" if define headless update
if $ANSIBLE_UPDATE
    :finish
endif

" Color setting
let g:gruvbox_contrast_dark = 'hard'
if exists('+termguicolors')
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif
let g:gruvbox_invert_selections = '0'
silent! colorscheme gruvbox
let g:lightline = {
      \ 'colorscheme': 'seoul256',
      \ }

" lsp setup
let g:diagnostic_enable_virtual_text = 1
let g:completion_matching_strategy_list = ['exact', 'substring', 'fuzzy']
augroup nowhitespaceattheend
    autocmd!
    autocmd BufEnter * lua require'completion'.on_attach()
augroup END
" configure my lsp setup
lua require'my_lsp_setup'.setup_lsp()

" Configuration specifics for/after plugins
if executable('rg')
    let g:rg_derive_root='true'
endif

" Whether if I want to use fzf or telescope
let s:use_fzf = 0

" Keyboard remap
nnoremap ]c ]czz
nnoremap [c [czz
inoremap <C-c> <ESC>
nnoremap <leader>h :wincmd h<CR>
nnoremap <leader>j :wincmd j<CR>
nnoremap <leader>k :wincmd k<CR>
nnoremap <leader>l :wincmd l<CR>
nnoremap <leader>u :UndotreeShow<CR>
nnoremap <leader>pv :vertical topleft wincmd v<bar> :Ex <bar> :vertical resize 30<CR>
nnoremap <silent> <Leader>+ :vertical resize +5<CR>
nnoremap <silent> <Leader>- :vertical resize -5<CR>
nnoremap <leader>V :vsp ~/.config/nvim/init.vim<CR>
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
nnoremap <leader>w :w<CR>
if s:use_fzf
    nnoremap <c-p> :Files<CR>
else
    nnoremap <c-p> <cmd>lua require'telescope.builtin'.find_files{find_command = vim.split(vim.env.FZF_DEFAULT_COMMAND, ' ')}<CR>
endif
if s:use_fzf
    nnoremap <leader>b :Buffers<CR>
else
    nnoremap <leader>b <cmd>lua require'telescope.builtin'.buffers{}<CR>
endif
nnoremap <leader><c-]> <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <leader>K     <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <leader>gD    <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <leader><c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <leader>1gD   <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <leader>gr    <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <leader>g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
nnoremap <leader>gW    <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
nnoremap <leader>gd    <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <leader>go    <cmd>OpenDiagnostic<CR>
nnoremap <leader>gn    <cmd>NextDiagnosticCycle<CR>
nnoremap <leader>gp    <cmd>PrevDiagnosticCycle<CR>
if executable('rg')
    command! -bang -nargs=* Rg
      \ call fzf#vim#grep(
      \   'rg -- '.shellescape(<q-args>), 1,
      \   fzf#vim#with_preview(), <bang>0)
    if s:use_fzf
        nnoremap <Leader>ps :Rg<SPACE>
        nnoremap Q :Rg <c-r><c-w>
    else
        nnoremap <Leader>ps <cmd>lua require('telescope.builtin').live_grep()<CR>
        nnoremap Q <cmd>lua require('telescope.builtin').grep_string()<CR>
    endif
else
    nnoremap Q :<c-u>vim /<c-r><c-w>/ **
endif

" If we can osc52 the clipboard
if ! empty($SSH_CLIENT)
    " See: https://www.reddit.com/r/vim/comments/ac9eyh/talk_i_gave_on_going_mouseless_with_vim_tmux/
    " See: https://gist.github.com/agriffis/70360287f9016fd8849b8150a4966469
    function! Osc52Yank()
        let buffer=system('base64 -w0', getreg('"'))
        let buffer=substitute(buffer, "\n$", "", "")
        let buffer="\e]52;c;".buffer."\x07"
        if ! exists('s:tty_found')
            let s:tty_found=system(
                \'tty &>/dev/null && tty || tty </proc/$PPID/fd/0 | grep /dev/'
                \)
        endif
        silent exe "!echo -ne ".shellescape(buffer)." > ".s:tty_found
    endfunction
    augroup sendToOsc52autocmd
        autocmd!
        autocmd TextYankPost * if v:event.operator ==# 'y' && v:event.regname == ''
            \| call Osc52Yank()
            \| endif
    augroup END
endif

" If we are wsl
if ! empty($WSL_INTEROP)
    function! ClipExeYank()
        let buffer=getreg('"')
        if executable('clip.exe')
            call system('clip.exe', buffer)
        endif
    endfunction
    augroup sendToClipExe
        autocmd!
        autocmd TextYankPost * if v:event.operator ==# 'y' && v:event.regname == ''
            \| call ClipExeYank()
            \| endif
    augroup END
endif

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
