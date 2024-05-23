let mapleader = " "

" if define headless update
" lua require('jerry.plugins')
" if $ANSIBLE_UPDATE
"     autocmd User PackerComplete quitall
"     PackerSync
"     finish
" endif

" Native settings
syntax on
filetype plugin on
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
" set number relativenumber
set signcolumn=no
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
set list
set shortmess+=c
set noshowmode
set shiftround
set background=dark
set splitbelow splitright
set termguicolors
set guicursor=i-ci-ve:block-blinkwait175-blinkoff150-blinkon175
set completeopt=menuone,noinsert,noselect
let g:netrw_banner = 0
let g:netrw_browse_split = 4
let g:netrw_winsize = 25
set nofoldenable
set scrolloff=5 " Make sure that cursor won't be too high
set cursorline
let g:vimsyn_embed = 'l'
let g:loaded_clipboard_provider = 1 " I don't need nvim to sync clipboard for me, I have my own tool
set grepprg=rg\ --line-number\ --color=never
set regexpengine=1
set diffopt+=iwhiteeol
set nofixendofline

let g:gruvbox_material_background = 'hard'
let g:gruvbox_material_foreground = 'material'
let g:gruvbox_material_better_performance = 0
colorscheme gruvbox-material

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
nnoremap <leader>r      <cmd>  silent exec '!tswitch -c nv'<CR>
nnoremap <leader>,.     <cmd>  call execute(getline('.'), '')<cr>
vnoremap <leader>,.     :<C-u> lua require('jerry.sourcer').eval_vimscript(table.concat(vim.fn['jerry#common#GetVisualSelectionAsList'](), "\n"))<cr>
nnoremap <leader>T      <cmd>  lua SL()<cr>
vnoremap <leader>T      :<c-u> lua SV()<cr>

nnoremap <leader>oe     <cmd> silent execute "!tmux send-keys -t :.+1 Up Enter"<cr>
nnoremap <leader>oo     <cmd> silent execute "!tmux send-keys -t :.-1 Up Enter"<cr>
nnoremap <leader>oa     <cmd> silent execute "!tmux send-keys -t :-.1 Up Enter"<cr>
nnoremap <leader>ou     <cmd> silent execute "!tmux send-keys -t :+.1 Up Enter"<cr>

nnoremap <leader>ty     <cmd> lua require('jerry.sourcer').lua_sourcer('SOURCE_THESE_LUAS_START', 'SOURCE_THESE_LUAS_END') <cr>
nnoremap <leader>ti     <cmd> lua require('jerry.sourcer').vim_sourcer('SOURCE_THESE_VIMS_START', 'SOURCE_THESE_VIMS_END') <cr>
nnoremap <leader>tp     <cmd> lua require('jerry.marker').mark_these('MARK_THIS_PLACE') <cr>

" Just a vairable quick print, delimited by space
nnoremap <leader>t.     <cmd> call system("tmux load-buffer -", expand('<cWORD>')."\r") <bar> silent execute "!tmux paste-buffer -t :.+1" <cr>
nnoremap <leader>t,     <cmd> call system("tmux load-buffer -", expand('<cWORD>')."\r") <bar> silent execute "!tmux paste-buffer -t :.-1" <cr>
" " for cpp and gdb
" nnoremap <leader>np <cmd> call system("tmux load-buffer -", "p ".expand('<cWORD>')."\r") <bar> silent execute "!tmux paste-buffer -t :.+1" <cr>

" Stay after the end of the block at the blank line
nnoremap <leader>tu     <cmd> call system("tmux load-buffer -", jerry#common#GetBlockSelection()."\r") <bar> silent execute "!tmux paste-buffer -t :.+1" <bar> exec "normal! '}" <bar> exec ':'.(search('[^ \t]', 'bceW') + 1)<cr>
nnoremap <leader>ta     <cmd> call system("tmux load-buffer -", jerry#common#GetBlockSelection()."\r") <bar> silent execute "!tmux paste-buffer -t :.-1" <bar> exec "normal! '}" <bar> exec ':'.(search('[^ \t]', 'bceW') + 1)<cr>
" " Stay at the last line of the block
" nnoremap <leader>tu     <cmd> call system("tmux load-buffer -", jerry#common#GetBlockSelection()."\r") <bar> silent execute "!tmux paste-buffer -t :.+1" <bar> exec "normal! '}" <bar> exec ':'.search('[^ \t]', 'bceW')<cr>
" nnoremap <leader>ta     <cmd> call system("tmux load-buffer -", jerry#common#GetBlockSelection()."\r") <bar> silent execute "!tmux paste-buffer -t :.-1" <bar> exec "normal! '}" <bar> exec ':'.search('[^ \t]', 'bceW')<cr>

nnoremap <leader>te     <cmd>  call system("tmux load-buffer -", substitute(getline(line('.')), '^[ \t]*', '', 'g')."\r") <bar> silent execute "!tmux paste-buffer -t :.+1" <cr>
nnoremap <leader>to     <cmd>  call system("tmux load-buffer -", substitute(getline(line('.')), '^[ \t]*', '', 'g')."\r") <bar> silent execute "!tmux paste-buffer -t :.-1" <cr>
" " rarely used
" nnoremap <leader>ta     <cmd>  call system("tmux load-buffer -", substitute(getline(line('.')), '^[ \t]*', '', 'g')."\r") <bar> silent execute "!tmux paste-buffer -t :-.1" <bar> silent execute "!tmux select-window -t :-.1" <cr>
" nnoremap <leader>tu     <cmd>  call system("tmux load-buffer -", substitute(getline(line('.')), '^[ \t]*', '', 'g')."\r") <bar> silent execute "!tmux paste-buffer -t :+.1" <bar> silent execute "!tmux select-window -t :+.1" <cr>

vnoremap <leader>te     :<c-u> call system("tmux load-buffer -", jerry#common#GetVisualSelection()."\r") <bar> silent execute "!tmux paste-buffer -t :.+1" <cr>
vnoremap <leader>to     :<c-u> call system("tmux load-buffer -", jerry#common#GetVisualSelection()."\r") <bar> silent execute "!tmux paste-buffer -t :.-1" <cr>
" " c++ with gdb
" vnoremap <leader>te     :<c-u> call system("tmux load-buffer -", "p ".jerry#common#GetVisualSelection()."\r") <bar> silent execute "!tmux paste-buffer -t :.+1" <cr>
" vnoremap <leader>to     :<c-u> call system("tmux load-buffer -", "p ".jerry#common#GetVisualSelection()."\r") <bar> silent execute "!tmux paste-buffer -t :.-1" <cr>
" " rarely used
" vnoremap <leader>ta     :<c-u> call system("tmux load-buffer -", jerry#common#GetVisualSelection()."\r") <bar> silent execute "!tmux paste-buffer -t :-.1" <bar> silent execute "!tmux select-window -t :-.1" <cr>
" vnoremap <leader>tu     :<c-u> call system("tmux load-buffer -", jerry#common#GetVisualSelection()."\r") <bar> silent execute "!tmux paste-buffer -t :+.1" <bar> silent execute "!tmux select-window -t :+.1" <cr>

nnoremap <c-p>          <cmd>  call jerry#common#FileFuzzySearch()<CR>
nnoremap <leader>po     <cmd>  lua require('telescope.builtin').oldfiles()<CR>
nnoremap <leader>/      <cmd>  call jerry#common#LinesFuzzySearch()<CR>
nnoremap <leader>b      <cmd>  call jerry#common#BufferFuzzySearch()<CR>
nnoremap Q              <cmd>  call jerry#common#WordFuzzySearch()<CR>
nnoremap <leader>ps     <cmd>  call jerry#common#GlobalFuzzySearch()<CR>
nnoremap <leader>qf     <cmd>  lua require('telescope.builtin').quickfix()<CR>
nnoremap <leader>pa     <cmd>  call jerry#common#CloseTab()<CR>

nnoremap <leader><c-]>  <cmd>  lua vim.lsp.buf.definition()<CR>
" [UNMAINTAINED] Lspsaga hasn't been maintained for a long time.
" nnoremap <leader>g<c-]> <cmd>  lua require'lspsaga.provider'.preview_definition()<CR>
nnoremap <leader>gd     <cmd>  lua vim.lsp.buf.declaration()<CR>
nnoremap <leader>gf     <cmd>  lua vim.lsp.buf.format()<CR>
vnoremap <leader>gf     <cmd>  '<,'>lua vim.lsp.buf.format()<CR>
nnoremap <leader>gD     <cmd>  lua vim.lsp.buf.implementation()<CR>
nnoremap <leader>gr     <cmd>  lua require('telescope.builtin').lsp_references()<CR>
" [UNMAINTAINED] Lspsaga hasn't been maintained for a long time.
" nnoremap <leader>gR     <cmd>  lua require('lspsaga.rename').rename()<CR>
nnoremap <leader>gR     <cmd>  lua vim.lsp.buf.rename()<CR>
nnoremap <leader>1gD    <cmd>  lua vim.lsp.buf.type_definition()<CR>
" [UNMAINTAINED] Lspsaga hasn't been maintained for a long time.
" nnoremap <leader>ga     <cmd>  lua require('lspsaga.codeaction').code_action()<CR>
nnoremap <leader>ga     <cmd>  lua vim.lsp.buf.code_action()<CR>
" [UNMAINTAINED] Lspsaga hasn't been maintained for a long time.
" vnoremap <leader>ga     <cmd>  '<,'>lua require('lspsaga.codeaction').range_code_action()<CR>
vnoremap <leader>ga     <cmd>  '<,'>lua vim.lsp.buf.range_code_action()<CR>
nnoremap <leader>K      <cmd>  lua vim.lsp.buf.hover()<CR>
nnoremap <leader>go     <cmd>  call jerry#common#ListSymbols()<CR>
" " TODO once the bus is closed, bring this back in
" " Case: https://github.com/glepnir/lspsaga.nvim/issues/241
" nnoremap <leader>K      <cmd>  lua require('lspsaga.hover').render_hover_doc()<CR>
" [UNMAINTAINED] Lspsaga hasn't been maintained for a long time.
" inoremap <c-k>          <cmd>  lua require('lspsaga.signaturehelp').signature_help()<CR>
inoremap <c-k>          <cmd>  lua vim.lsp.buf.signature_help()<CR>

nnoremap <leader>gO     <cmd>  lua vim.diagnostic.set_loclist() <CR>
nnoremap <leader>gs     <cmd>  LspInfo <CR>
nnoremap <leader>gg     <cmd>  lua vim.lsp.stop_client(vim.lsp.get_active_clients())<CR>
nnoremap <leader>gn     <cmd>  lua vim.diagnostic.goto_next { wrap = false, severity = 'Error' }<CR>
nnoremap <leader>gp     <cmd>  lua vim.diagnostic.goto_prev { wrap = false, severity = 'Error' }<CR>
nnoremap <leader>gN     <cmd>  lua vim.diagnostic.goto_next { wrap = false, severity_limit = 'Warning' }<CR>
nnoremap <leader>gP     <cmd>  lua vim.diagnostic.goto_prev { wrap = false, severity_limit = 'Warning' }<CR>

" Find all the syntax highlights
nnoremap <leader>Hl <cmd>so $VIMRUNTIME/syntax/hitest.vim<cr>

" Find syntax match
nnoremap <silent> <leader>Hh :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name")
    \ . '> trans<' . synIDattr(synID(line("."),col("."),0),"name")
    \ . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name")
    \ . ">"<CR>

vnoremap <leader>p "0p
nnoremap <leader>fm vip:g/\|/Tab/\|/<cr>
nnoremap ]c ]czz
nnoremap [c [czz
nnoremap n nzz
nnoremap N Nzz
inoremap <C-c> <ESC>
nnoremap ; :
nnoremap : ;
vnoremap ; :
vnoremap : ;

" Has to disable this on 6/8/2024 where it broke my @h debug macro. Github issue https://github.com/neovim/neovim/issues/28287, GR 28289
vunmap @
vunmap Q

" Takes too long for big project
" nnoremap <leader>gW    <cmd> lua require'telescope.builtin'.lsp_workspace_symbols{}<CR>

" " Unused items, but sad to delete them
" vnoremap J :m '>+1<CR>gv=gv
" vnoremap K :m '<-2<CR>gv=gv
" nnoremap <silent> <Leader>+ :vertical resize +5<CR>
" nnoremap <silent> <Leader>- :vertical resize -5<CR>

" " Use toclip to send content to clipboard
" augroup toClipBoard
"     autocmd!
"     autocmd TextYankPost * if v:event.operator ==# 'y' && v:event.regname == ''
"         \|   let ret = system('toclip', getreg('"'))
"         \|   if exists('g:toclip_verbose')
"         \|     echom 'toclip: ' . ret
"         \|   endif
"         \| endif
" augroup END

let g:clip_supplier = ['toclip']
" let g:clip_supplier = []
" if executable('toclip') == 1
"     let g:clip_supplier = ['toclip']
" elseif executable('win32yank.exe')
"     let g:clip_supplier = ['win32yank.exe', '-i', '--crlf']
" elseif executable('clip.exe')
"     let g:clip_supplier = ['clip.exe']
" endif

" Use clip.exe to send content to clipboard
augroup toClipBoard
    autocmd!
    if len(g:clip_supplier) > 0
        autocmd TextYankPost * if v:event.operator ==# 'y' && v:event.regname == ''
            \|   let ret = system(g:clip_supplier, getreg('"'))
            \|   if exists('g:toclip_verbose')
            \|     echom join(g:clip_supplier, ' ') . ' (' . v:shell_error .'): ' . ret
            \|   endif
            \| endif
    else
        echohl WarningMsg
        echom "No clipboard tool found. Need to be toclip, win32yank.exe or clip.exe"
        echohl None
    endif
augroup END

augroup Lsp
    autocmd!
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

augroup manyMapView
    autocmd!
    autocmd BufEnter,BufWinEnter,TabEnter many_maps.vim iabbrev newb lua <<EOF<cr>S[[<cr><cr>]]<cr>EOF<up><up>
augroup END

augroup indentConfig
    autocmd!
    autocmd BufEnter,BufWinEnter,TabEnter * iabbrev vimet vim:et ts=4 sts=4 sw=4
augroup END

augroup markdownFenceHighlight
    autocmd!
    autocmd BufEnter,BufWinEnter,TabEnter *.md iabbrev ats <c-r>=strftime('%Y-%m-%d %A')<cr>
    autocmd BufEnter,BufWinEnter,TabEnter *.md iabbrev #T # <c-r>=strftime('%Y-%m-%d %A')<cr>
    autocmd BufEnter,BufWinEnter,TabEnter *.md iabbrev #t # <c-r>=strftime('%Y-%m-%d %A')<cr>
    autocmd BufEnter,BufWinEnter,TabEnter *.md iabbrev ##T ## <c-r>=strftime('%Y-%m-%d %A')<cr>
    autocmd BufEnter,BufWinEnter,TabEnter *.md iabbrev ##t ## <c-r>=strftime('%Y-%m-%d %A')<cr>
    autocmd BufEnter,BufWinEnter,TabEnter *.md iabbrev ###T ### <c-r>=strftime('%Y-%m-%d %A')<cr>
    autocmd BufEnter,BufWinEnter,TabEnter *.md iabbrev ###t ### <c-r>=strftime('%Y-%m-%d %A')<cr>
    autocmd BufEnter,BufWinEnter,TabEnter *.md iabbrev ####T #### <c-r>=strftime('%Y-%m-%d %A')<cr>
    autocmd BufEnter,BufWinEnter,TabEnter *.md iabbrev ####t #### <c-r>=strftime('%Y-%m-%d %A')<cr>
    autocmd BufEnter,BufWinEnter,TabEnter *.md let g:markdown_fenced_languages += ['python', 'ps1', 'cpp', 'bash', 'vim', 'matlab']
    autocmd BufEnter,BufWinEnter,TabEnter *.md silent! exec 'edit'

    autocmd BufEnter,BufWinEnter,TabEnter *.ps1 iabbrev nfor <c-r>=jerry#common#JiraNoFormat()<cr><up>
    autocmd BufEnter,BufWinEnter,TabEnter *.ps1 iabbrev code; <c-r>=jerry#common#JiraCodeFormat()<cr><up>
augroup END

augroup sourcerTheseCode
    autocmd!
    autocmd BufEnter,BufWinEnter,TabEnter * iabbrev tit SOURCE_THESE_VIMS_START<cr><cr>echom 'Sourced'<cr>SOURCE_THESE_VIMS_END<Up><Up>
    autocmd BufEnter,BufWinEnter,TabEnter * iabbrev tyt SOURCE_THESE_LUAS_START<cr><cr>print('Sourced')<cr>SOURCE_THESE_LUAS_END<Up><Up>
augroup END

augroup markerTheseCode
    autocmd!
    autocmd BufEnter,BufWinEnter,TabEnter * iabbrev tpt MARK_THIS_PLACE
augroup END

augroup DisableSomeSyntax
    autocmd!
    autocmd BufEnter,BufWinEnter,TabEnter *.groovy,*.html syntax sync fromstart
augroup END

