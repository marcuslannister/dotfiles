""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Platform
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! MySys()
    if has("win32") || has("win64")
        return "windows"
    elseif has("mac")
        return "mac"
    else
        return "linux"
    endif
endfunction

if MySys()=="windows"
    if has("gui_running")
        source $VIMRUNTIME/mswin.vim
        behave mswin
        au GUIEnter * simalt ~x
        set shell=C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe\ -ExecutionPolicy\ Bypass
    endif
endif

let $vimrc_file = '~/.vimrc'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" An example for a vimrc file.
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2019 Jan 26
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Get the defaults that most users want.
unlet! skip_defaults_vim
source $VIMRUNTIME/defaults.vim

" Put these in an autocmd group, so that we can delete them easily.
augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78
augroup END

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plug
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call plug#begin('~/.vim/plugged')

" Shorthand notation; fetches https://github.com/junegunn/vim-easy-align
" old plugin
"Plug 'vim-airline/vim-airline'
"Plug 'vim-airline/vim-airline-themes'
"Plug 'townk/vim-autoclose'

" Plug 'pomakhin/cvim'
"Plug 'vim-scripts/DrawIt'
"Plug 'scrooloose/nerdtree'
"Plug 'scrooloose/nerdcommenter'
" Plug 'vim-scripts/bufexplorer.zip'
"Plug 'scrooloose/syntastic'
"Plug 'fidian/hexmode'
"Plug 'majutsushi/tagbar'
"Plug 'shemerey/vim-project'
"Plug 'vim-scripts/sessionman.vim'
"Plug 'ludovicchabant/vim-gutentags'
"Plug 'w0rp/ale'
"Plug 'Chiel92/vim-autoformat'
" Plug 'mkitt/tabline.vim'
"Plug 'Shougo/denite.nvim'
"Plug 'chemzqm/denite-git'
" Plug 'vim-scripts/a.vim'
"Plug 'inkarkat/vim-mark'
" Plug 'aklt/plantuml-syntax'
"Plug 'dhruvasagar/vim-table-mode'
"Plug 'wolfgangmehner/lua-support'
"Plug 'vim-scripts/TagHighlight'

" file
Plug 'inkarkat/vim-ingo-library'
Plug 'vim-scripts/writebackup' "DEPENDENCIES vim-ingo-library"

" language
" let g:polyglot_disabled = ['ftdetect']
" Plug 'sheerun/vim-polyglot'
" Plug 'tpope/vi-commentary'
Plug 'tomtom/tcomment_vim'
Plug 'skywind3000/vim-auto-popmenu'
Plug 'skywind3000/vim-dict'

" color
" Plug 'raphamorim/lucario'
" Plug 'morhetz/gruvbox'
" Plug 'haishanh/night-owl.vim'
" Plug 'sjl/badwolf'
" Plug 'joshdick/onedark.vim'
" Plug 'rakr/vim-one'
" Plug 'sainnhe/gruvbox-material'
" Plug 'sonph/onehalf', {'rtp': 'vim/'}
" Plug 'jonathanfilip/vim-lucius'
" Plug 'ayu-theme/ayu-vim'
" Plug 'arcticicestudio/nord-vim'
" Plug 'cocopon/iceberg.vim'
Plug 'NLKNguyen/papercolor-theme'
" Plug 'cormacrelf/vim-colors-github'
" Plug 'rakr/vim-two-firewatch'
" Plug 'tomasr/molokai'
" Plug 'kyoz/purify'
" Plug 'sainnhe/edge'
" Plug 'chriskempson/base16-vim'

if MySys()=="windows"
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'

" Plantuml
" Plug 'scrooloose/vim-slumlord'

" Plug 'aklt/plantuml-syntax'
" Plug 'tyru/open-browser.vim'
" Plug 'weirongxu/plantuml-previewer.vim'
" let g:openbrowser_browser_commands = [
" \   {'name': 'C:\Program Files (x86)\BraveSoftware\Brave-Browser\Application\brave.exe',
" \    'args': ['start', '{browser}', '{uri}']}
" \]
endif

" Initialize plugin system
call plug#end()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Color and Font
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has("gui_running")   " GUI color and font settings
    set gfn=JetBrains\ Mono:h11:cANSI
    set gfw=JetBrains\ Mono:h10:cGB2312
else
    if has('termguicolors')
        " set Vim-specific sequences for RGB colors
        let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
        let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

        " terminal color settings
        set termguicolors
    endif

    " highlight Normal ctermbg=NONE guibg=NONE
    " highlight NonText ctermbg=NONE guibg=NONE
endif

    " set background=dark
    set background=light

    " set contrast
    " this configuration option should be placed before `colorscheme gruvbox-material`
    " available values: 'hard', 'medium'(default), 'soft'
    " let g:gruvbox_material_background = 'medium'
    " colorscheme gruvbox-material

    " colorscheme gruvbox
    " colorscheme night-owl
    " colorscheme badwolf
    " colorscheme lucario
    " colorscheme one
    " colorscheme onedark
    " colorscheme onehalfdark
    " colorscheme onehalflight
    " colorscheme lucius
    " colorscheme iceberg
    " colorscheme molokai

    " let g:github_colors_soft = 1
    " colorscheme github

    colorscheme PaperColor
    let g:PaperColor_Theme_Options = {
      \   'language': {
      \     'python': {
      \       'highlight_builtins' : 1
      \     },
      \     'cpp': {
      \       'highlight_standard_library': 1
      \     },
      \     'c': {
      \       'highlight_builtins' : 1
      \     }
      \   }
      \ }

    " let base16colorspace=256  " Access colors present in 256 colorspace
    " colorscheme base16-papercolor-light

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""i
" backup
set backup
set backupdir=~/.local/share/vim/backup//
set directory=~/.local/share/vim/swap//
set undodir=~/.local/share/vim/undo//
let g:WriteBackup_BackupDir = '~/.local/share/vim/backup//'

" search
set ignorecase      " ignore case when searching
set smartcase       " ignore case if search pattern

syntax on             " syntax highlight
set hlsearch          " search highlighting
set incsearch         " incremental search
set nowrapscan        " stop searches wrap around the end of the file

set ruler             " show the cursor position all the time

" file
filetype on           " Enable filetype detection
filetype indent on    " Enable filetype-specific indenting
filetype plugin on    " Enable filetype-specific plugins

au FileType Makefile set noexpandtab
autocmd FileType yaml,yml setlocal ts=2 sts=2 sw=2 expandtab

set autoread          " auto read when file is changed from outside
" Triger `autoread` when files changes on disk
" https://unix.stackexchange.com/questions/149209/refresh-changed-content-of-file-opened-in-vim/383044#383044
" https://vi.stackexchange.com/questions/13692/prevent-focusgained-autocmd-running-in-command-line-editing-mode
autocmd FocusGained,BufEnter,CursorHold,CursorHoldI *
    \ if mode() !~ '\v(c|r.?|!|t)' && getcmdwintype() == '' | checktime | endif

" Notification after file change
" https://vi.stackexchange.com/questions/13091/autocmd-event-for-autoread
autocmd FileChangedShellPost *
    \ echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None

" Disable automatic comment insertion
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" dislplay
set cursorline        " highlight current line
"hi CursorLine
set number            " display line number
" set nonu            " do not display line number

"Cursor settings:
"  1 -> blinking block
"  2 -> solid block
"  3 -> blinking underscore
"  4 -> solid underscore
"  5 -> blinking vertical bar
"  6 -> solid vertical bar
" Insert mode
let &t_SI = "\<Esc>[3 q"
" Normal mode
let &t_EI = "\<Esc>[2 q"

" 水平切割窗口时，默认在右边显示新窗口
set splitright

" text edit
set bs=2          " allow backspacing over everything in insert mode
set autoindent    " auto indentation

" TAB setting
set expandtab        "replace <TAB> with spaces
set softtabstop=4
set shiftwidth=4
set tabstop=4
set list
set listchars=tab:>-,trail:-

set breakindent

" fold
" zo opens a fold at the cursor.
" z Shift+o opens all folds at the cursor.
" zc closes a fold at the cursor.
" zm increases the foldlevel by one.
" z Shift+m closes all open folds.
" zr decreases the foldlevel by one.
" z Shift+r decreases the foldlevel to zero -- all folds will be open.

" set foldmethod=indent
" set foldnestmax=10
" set nofoldenable
" set foldlevel=2

if has('folding')
    " 允许代码折叠
    set foldenable

    " 代码折叠默认使用缩进
    set fdm=indent

    " 默认打开所有缩进
    set foldlevel=99
endif

" zf1G      : fold everything before this line [N]
" " folding : hide sections to allow easier comparisons
" zf}                               : fold paragraph using motion
" v}zf                              : fold paragraph using visual
" zf'a                              : fold to mark
" zo                                : open fold
" zc                                : re-close fold
" " also visualise a section of code then type zf [N]
" :help folding
" zfG      : fold everything after this line [N]

" encoding
if MySys()=="windows"
    set fileencodings=utf-8,ucs-bom,cp936,big5
    set fileencoding=utf-8
    set encoding=utf-8
endif

" menu
if MySys()=="windows"
    "设置gvim隐藏菜单栏，工具栏，滚动条
    set guioptions-=m  "remove menu bar
    set guioptions-=T  "remove toolbar
    set guioptions-=r  "remove right-hand scroll bar
    set guioptions-=L  "remove left-hand scroll bar
endif

set paste

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" USEFUL SHORTCUTS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" set leader to ,
let mapleader=" "
let g:mapleader=" "

"Fast reloading of the .vimrc
map <silent> <leader>so :source $vimrc_file<cr>

"Fast editing of .vimrc
map <silent> <leader>ed :e $vimrc_file<cr>

" display
" toggled display line number
nmap <leader>nn :set invnumber<CR>

" tab
map <M-1> 1gt
map <M-2> 2gt
map <M-3> 3gt
map <M-4> 4gt
map <M-5> 5gt
map <M-6> 6gt
map <M-7> 7gt
map <M-8> 8gt
map <M-9> 9gt

map <C-t><C-t> :tabnew<CR>
map <A-w> :tabclose<CR>
map <leader>tn :tabnew<CR>
map <leader>tc :tabclose<CR>

map <F3> :tabn<cr>
map <F2> :tabp<cr>

" window
map <leader>wq <C-W><C-Q>
map <leader>wo <C-W><C-O>
map <leader>wv <C-W><C-V>
map <leader>ww <C-W><C-W>

" file
" save file
map <silent> <leader>w :w<cr>
map <silent> <leader>bs :w<cr>

" system
map <silent> <leader>qq :q<cr>
map <silent> <leader>qi :q!<cr>
map <silent> <leader>qa :qall<cr>
map <A-o> :only<CR>
map <A-q> :q<CR>

" text edit
"replace the last searched text with the last yanked text in the entire buffer
map <leader>rep :%s//\=@"/g"
" deletes any trailing whitespace at the end of each line.
" If no trailing whitespace is found no change occurs, and the e flag means no error is displayed.
map <leader>dtw :%s/\s\+$//e
" Fix indentation
map <leader>gg gg=G
" convert tab to space
map <leader>rt :retab
" remove ^M
map <leader>ffu :set ff=unix<CR>
" remove ^M when set ff=unix can not work
map <leader>ffd :e ++ff=dos<CR>
":%s/<Ctrl-V><Ctrl-M>/\r/g<Paste>

" Highlight tabs as errors.
map <leader>me :match Error /\t/<cr>

" search
" turn off search highlighting
nmap <leader>. :nohl<CR>

" commander line
" Bash like keys for the command line
cnoremap <C-A>      <Home>
cnoremap <C-E>      <End>
cnoremap <C-K>      <C-U>
" <ctrl+r>" copy yanked text to VI command prompt

" :cd. change working directory to that of the current file
cmap cd. lcd %:p:h
nnoremap cd :cd %:p:h<CR>

" text edit
" ,p toggles paste mode
nmap <leader>p :set paste!<BAR>set paste?<CR>
" allow multiple indentation/deindentation in visual mode
vnoremap < <gv
vnoremap > >gv

" set clipboard=unnamed
" inoremap <S-Insert> <ESC>"+p`]a

" conver space to slash with space
map <leader>css :%s/ /\\ /g<CR>:%s/(/\\(/g<CR>:%s/)/\\)/g<CR>

" copy buffer
map <leader>kyw "kyiw
map <leader>kp "kp

" Copy the current word or visually selected text to the clipboard:
nnoremap <F6> "+yiw
vnoremap <F6> "+y

" Replace the current word or visually selected text with the clipboard contents:
nnoremap <F7> viw"+p
vnoremap <F7> "+p

" buffer
map <silent> <leader>bw :bw<cr>
map <silent> <leader>bd :bd<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" https://dougblack.io/words/a-good-vimrc.html
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" set wildmenu            " visual autocomplete for command menu
set lazyredraw          " redraw only when we need to.
set showmatch           " highlight matching [{()}]

" move vertically by visual line
" nnoremap j gj
" nnoremap k gk

" highlight last inserted text
nnoremap gV `[v`]

" jk is escape
inoremap jk <esc>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" https://vimrcfu.com
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" View and paste from a register
function! Reg()
    reg
    echo "Register: "
    let char = nr2char(getchar())
    if char != "\<Esc>"
        execute "normal! \"".char."p"
    endif
    redraw
endfunction

command! -nargs=0 Reg call Reg()

" Keep search matches in the middle of the screen
nnoremap n nzz
nnoremap N Nzz

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin Setting
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"-------------------------------------------------------------------------------
" Commentary
"-------------------------------------------------------------------------------
" nmap <silent> <leader>cl <Plug>CommentaryLine<CR>
" vmap <silent> <leader>cl <Plug>CommentaryLine<CR>
" nmap <silent> <leader>cc <Plug>Commentary<CR>
" vmap <silent> <leader>cc <Plug>Commentary<CR>

"-------------------------------------------------------------------------------
" tcomment_vim
"-------------------------------------------------------------------------------
nmap <silent> <leader>c<space> <c-_>p<cr>
vmap <silent> <leader>c<space> <c-_>p<cr>
nmap <silent> <leader>cc :TComment<cr>
vmap <silent> <leader>cc :TComment<cr>
nmap <silent> <leader>cb :TCommentBlock<cr>
vmap <silent> <leader>cb :TCommentBlock<cr>

"-------------------------------------------------------------------------------
" vim-auto-popmenu
"-------------------------------------------------------------------------------
" enable this plugin for filetypes, '*' for all files.
let g:apc_enable_ft = {'text':1, 'markdown':1, 'php':1, 'vim':1 }

" source for dictionary, current or other loaded buffers, see ':help cpt'
set cpt=.,k,w,b

" don't select the first item.
set completeopt=menu,menuone,noselect

" suppress annoy messages.
set shortmess+=c

" 总是显示状态栏
set laststatus=2

set statusline=                                 " 清空状态了
set statusline+=\ %F                            " 文件名
set statusline+=\ [%1*%M%*%n%R%H]               " buffer 编号和状态
set statusline+=%=                              " 向右对齐
set statusline+=\ %y                            " 文件类型

" 最右边显示文件编码和行号等信息，并且固定在一个 group 中，优先占位
set statusline+=\ %0(%{&fileformat}\ [%{(&fenc==\"\"?&enc:&fenc).(&bomb?\",BOM\":\"\")}]\ %v:%l/%L%)

" copy to attached terminal using the yank(1) script:
" https://github.com/sunaku/home/blob/master/bin/yank
function! Yank(text) abort
  let escape = system('yank', a:text)
  if v:shell_error
    echoerr escape
  else
    call writefile([escape], '/dev/tty', 'b')
  endif
endfunction
noremap <silent> <Leader>y y:<C-U>call Yank(@0)<CR>

" automatically run yank(1) whenever yanking in Vim
" (this snippet was contributed by Larry Sanderson)
function! CopyYank() abort
  call Yank(join(v:event.regcontents, "\n"))
endfunction
autocmd TextYankPost * call CopyYank()

