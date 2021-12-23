
" if define headless update
lua require('jerry.plugins')
if $ANSIBLE_UPDATE
    autocmd User PackerComplete quitall
    PackerSync
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
set shiftround
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
set diffopt+=iwhiteeol

colorscheme xcodedarkhc

" load everything lua
lua require('jerry')

" Whether if I want to use fzf or telescope
let g:rg_derive_root='true'
let g:use_fzf = 0

" rg function to use later
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg -- '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview(), <bang>0)

" Key map
nnoremap <leader>h      <cmd>  wincmd h<CR>
nnoremap <leader>j      <cmd>  wincmd j<CR>
nnoremap <leader>k      <cmd>  wincmd k<CR>
nnoremap <leader>l      <cmd>  wincmd l<CR>
nnoremap <leader>U      <cmd>  UndotreeShow<CR>
nnoremap <leader>pv     <cmd>  vertical topleft wincmd v<bar> Ex <bar> vertical resize 50<CR>
nnoremap <leader>pp     <cmd>  call jerry#common#TogglePasteMode()<CR>
nnoremap <leader>v      <cmd>  vertical botright split ~/repos/dotfiles/neovim/.config/nvim/init.vim <CR>
nnoremap <leader>V      <cmd>  exec("lua require('jerry.telescope.pickers').find_dotfiles{}") <bar> lcd ~/repos/dotfiles <CR>
" nnoremap <leader>r      <cmd>  FS<CR>
" nnoremap <leader>R      <cmd>  FSOffset -3<CR>
nnoremap <leader>r      <cmd>  silent exec '!tswitch'<CR>
nnoremap <leader>E      <cmd>  .source<cr>
vnoremap <leader>E      :<c-u> '<,'>source<cr>
nnoremap <leader>T      <cmd>  lua SL()<cr>
vnoremap <leader>T      :<c-u> lua SV()<cr>

nnoremap <leader>te     <cmd>  silent execute ".w !tmux load-buffer -"  <bar> silent execute "!tmux paste-buffer -t :.+" <cr>
nnoremap <leader>to     <cmd>  silent execute ".w !tmux load-buffer -"  <bar> silent execute "!tmux paste-buffer -t :.+2" <cr>
nnoremap <leader>ta     <cmd>  silent execute ".w !tmux load-buffer -"  <bar> silent execute "!tmux paste-buffer -t :-" <bar> silent execute "!tmux select-window -t :-.1" <cr>
nnoremap <leader>tu     <cmd>  silent execute ".w !tmux load-buffer -"  <bar> silent execute "!tmux paste-buffer -t :+" <bar> silent execute "!tmux select-window -t :+.1" <cr>

" vnoremap <leader>te     :<c-u> silent execute "'<,'>w !tmux load-buffer -"  <bar> silent execute "!tmux paste-buffer -t :.+" <cr>
" vnoremap <leader>to     :<c-u> silent execute "'<,'>w !tmux load-buffer -"  <bar> silent execute "!tmux paste-buffer -t :.+2" <cr>
" vnoremap <leader>ta     :<c-u> silent execute "'<,'>w !tmux load-buffer -"  <bar> silent execute "!tmux paste-buffer -t :-" <bar> silent execute "!tmux select-window -t :-.1" <cr>
" vnoremap <leader>tu     :<c-u> silent execute "'<,'>w !tmux load-buffer -"  <bar> silent execute "!tmux paste-buffer -t :+" <bar> silent execute "!tmux select-window -t :+.1" <cr>

vnoremap <leader>te     :<c-u> call system("tmux load-buffer -", jerry#common#GetVisualSelection()."\r") <bar> silent execute "!tmux paste-buffer -t :.+" <cr>
vnoremap <leader>to     :<c-u> call system("tmux load-buffer -", jerry#common#GetVisualSelection()."\r") <bar> silent execute "!tmux paste-buffer -t :.+2" <cr>
vnoremap <leader>ta     :<c-u> call system("tmux load-buffer -", jerry#common#GetVisualSelection()."\r") <bar> silent execute "!tmux paste-buffer -t :-" <bar> silent execute "!tmux select-window -t :-.1" <cr>
vnoremap <leader>tu     :<c-u> call system("tmux load-buffer -", jerry#common#GetVisualSelection()."\r") <bar> silent execute "!tmux paste-buffer -t :+" <bar> silent execute "!tmux select-window -t :+.1" <cr>

nnoremap <c-p>          <cmd>  call jerry#common#FileFuzzySearch()<CR>
nnoremap <leader>/      <cmd>  call jerry#common#LinesFuzzySearch()<CR>
nnoremap <leader>b      <cmd>  call jerry#common#BufferFuzzySearch()<CR>
nnoremap <leader>o      <cmd>  call jerry#common#ListSymbols()<CR>
nnoremap Q              <cmd>  call jerry#common#WordFuzzySearch()<CR>
nnoremap <leader>ps     <cmd>  call jerry#common#GlobalFuzzySearch()<CR>
nnoremap <leader>qf     <cmd>  lua require('telescope.builtin').quickfix()<CR>
nnoremap <leader>pa     <cmd>  call jerry#common#CloseTab()<CR>

nnoremap <leader><c-]>  <cmd>  lua vim.lsp.buf.definition()<CR>
nnoremap <leader>g<c-]> <cmd>  lua require'lspsaga.provider'.preview_definition()<CR>
nnoremap <leader>gd     <cmd>  lua vim.lsp.buf.declaration()<CR>
nnoremap <leader>gf     <cmd>  lua vim.lsp.buf.formatting()<CR>
vnoremap <leader>gF     <cmd>  '<,'>lua vim.lsp.buf.range_formatting()<CR>
nnoremap <leader>gD     <cmd>  lua vim.lsp.buf.implementation()<CR>
nnoremap <leader>gr     <cmd>  lua require('telescope.builtin').lsp_references()<CR>
nnoremap <leader>gR     <cmd>  lua require('lspsaga.rename').rename()<CR>
nnoremap <leader>1gD    <cmd>  lua vim.lsp.buf.type_definition()<CR>
nnoremap <leader>ga     <cmd>  lua require('lspsaga.codeaction').code_action()<CR>
vnoremap <leader>ga     <cmd>  '<,'>lua require('lspsaga.codeaction').range_code_action()<CR>
nnoremap <leader>K      <cmd>  lua vim.lsp.buf.hover()<CR>
" " TODO once the bus is closed, bring this back in
" " Case: https://github.com/glepnir/lspsaga.nvim/issues/241
" nnoremap <leader>K      <cmd>  lua require('lspsaga.hover').render_hover_doc()<CR>
inoremap <c-k>          <cmd>  lua require('lspsaga.signaturehelp').signature_help()<CR>

nnoremap <leader>go     <cmd>  lua vim.diagnostic.set_loclist() <CR>
nnoremap <leader>gs     <cmd>  LspInfo <CR>
nnoremap <leader>gg     <cmd>  lua vim.lsp.stop_client(vim.lsp.get_active_clients())<CR>
nnoremap <leader>gn     <cmd>  lua vim.diagnostic.goto_next { wrap = false, severity = 'Error' }<CR>
nnoremap <leader>gp     <cmd>  lua vim.diagnostic.goto_prev { wrap = false, severity = 'Error' }<CR>
nnoremap <leader>gN     <cmd>  lua vim.diagnostic.goto_next { wrap = false, severity_limit = 'Warning' }<CR>
nnoremap <leader>gP     <cmd>  lua vim.diagnostic.goto_prev { wrap = false, severity_limit = 'Warning' }<CR>

" Find all the syntax highlights
nnoremap <leader>nl <cmd>so $VIMRUNTIME/syntax/hitest.vim<cr>

" Find syntax match
nnoremap <silent> <leader>nh :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name")
    \ . '> trans<' . synIDattr(synID(line("."),col("."),0),"name")
    \ . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name")
    \ . ">"<CR>

vnoremap <leader>p "_dP
nnoremap <leader>fm vip:g/\|/Tab/\|/<cr>
nnoremap ]c ]czz
nnoremap [c [czz
inoremap <C-c> <ESC>
nnoremap ; :
nnoremap : ;
vnoremap ; :
vnoremap : ;

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
        \|   let ret = system('toclip', getreg('"'))
        \|   if exists('g:toclip_verbose')
        \|     echom 'toclip: ' . ret
        \|   endif
        \| endif
augroup END

augroup Lsp
    autocmd!
    autocmd BufEnter,BufWinEnter,TabEnter *.rs :lua require'lsp_extensions'.inlay_hints{}
    autocmd BufReadPost,FileReadPost lua require "lsp_signature".on_attach()
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
    autocmd BufEnter,BufWinEnter,TabEnter *.groovy,*.html syntax sync fromstart
augroup END

