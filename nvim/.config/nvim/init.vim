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
set background=dark
set splitbelow splitright
highlight ColorColumn ctermbg=0 guibg=lightgrey
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 25
set nofoldenable

" Some plugin setups run before plugin loaded
let g:polyglot_disabled = ['powershell']

" Plugin manager section
"   Install this plugin manager from https://github.com/junegunn/vim-plug
call plug#begin('~/.vim/plugged')
Plug 'gruvbox-community/gruvbox'
Plug 'vim-utils/vim-man'
Plug 'mbbill/undotree'
Plug 'tomtom/tcomment_vim'
Plug 'tpope/vim-surround'
Plug 'michaeljsmith/vim-indent-object'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'pprovost/vim-ps1'
Plug 'godlygeek/tabular'
Plug 'sheerun/vim-polyglot'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
" fzf works great with fd and configured as
"  if command -v fd &>/dev/null; then
"      export FZF_DEFAULT_COMMAND='fd --type file --color=always'
"      export FZF_DEFAULT_OPTS="--ansi"
"  elif command -v fdfind &>/dev/null; then
"      export FZF_DEFAULT_COMMAND='fdfind --type file --color=always'
"      export FZF_DEFAULT_OPTS="--ansi"
"      alias fd=fdfind
"  fi
call plug#end()

" Color setting
colorscheme gruvbox
let g:gruvbox_contrast_dark = 'hard'
if exists('+termguicolors')
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif
let g:gruvbox_invert_selections = '0'

" Configuration specifics for/after plugins
if executable('rg')
    let g:rg_derive_root='true'
endif

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
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
nnoremap <leader>w :w<CR>
nnoremap <c-p> :Files<CR>
nnoremap <leader>b :Buffers<CR>
if executable('rg')
    nnoremap <Leader>ps :Rg<SPACE>
    nnoremap Q :Rg <c-r><c-w>
else
    nnoremap Q :<c-u>vim /<c-r><c-w>/ %
endif

" If we can osc52 the clipboard
if $SSH_CLIENT
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

" Since last version
"  Added new plugin vim-osc52 and associated autocommand to send to osc52
"  Replace with custom osc function as the one from the plugin doesn't work
"    for nvim
"  Add tty found capability as newer version cannot access /dev/tty directly
"  Remove project specific to local folder
"  Add additional check that only yank to osc52 with unnamed register
"  When invoke from the command line reading stdin, the tty detection needs to
"    be updated, now it will check everytime it runs the function
"  Add key map to do ]c [c to ]czz [czz
"  Add polyglot and disable polyglot to load powershell
"  Map over Q so I don't accidentally typed it
"  Set fold method to manual
"  Add tabular to easy align data
