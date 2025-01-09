"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
"               ██╗   ██╗██╗███╗   ███╗██████╗  ██████╗
"               ██║   ██║██║████╗ ████║██╔══██╗██╔════╝
"               ██║   ██║██║██╔████╔██║██████╔╝██║
"               ╚██╗ ██╔╝██║██║╚██╔╝██║██╔══██╗██║
"                ╚████╔╝ ██║██║ ╚═╝ ██║██║  ██║╚██████╗
"                 ╚═══╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

syntax on
colorscheme evening

" Enable type file detection. Vim will be able to try to detect the type of file in use.
filetype on
" Load an indent file for the detected file type.
filetype indent on

" Add numbers to the file.
set number
" Show partial command you type in the last line of the screen.
set showcmd
" Show the mode you are on the last line.
set showmode
" Cursor line highlight
set cursorline

" Better mouse integration
set mouse=a

" Set shift width to 4 spaces.
set shiftwidth=4

" Set tab width to 4 columns.
set tabstop=4

" Use space characters instead of tabs.
set expandtab

" Set indentation
set autoindent
set smartindent

" Do not wrap lines. Allow long lines to extend as far as the line goes.
set nowrap

" when scrolling, keep cursor 3 lines away from screen border
set scrolloff=7

" Wild menu
set wildmenu
set wildmode=list:longest
set wildignore=*.docx,*.so,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.deb,*.zip,*.img,*.xlsx

" Highlight matching brackets [{()}]
set showmatch

" Search tweaks
set incsearch
set ignorecase
set smartcase
set hlsearch
" Remove search highlight - This binds the command “:nohlsearch” with ,<spacebar> combo
nnoremap <leader><CR> :nohlsearch<CR>

" Code folding
set foldenable

" Fold blocks longet than 10 lines
set foldlevelstart=10

" Bind <spacebar> for opening/closing folds
nnoremap <space> za
set foldmethod=indent

" PLUGINS ---------------------------------------------------------------- {{{

" call plug#begin('~/.vim/plugged')

"  Plug 'dense-analysis/ale'

"  Plug 'preservim/nerdtree'

" call plug#end()

" }}}

" MAPPINGS --------------------------------------------------------------- {{{

" Type jj to exit insert mode quickly.
inoremap jj <Esc>

" Yank from cursor to the end of line.
nnoremap Y y$

" Map the F5 key to run a Python script inside Vim.
" We map F5 to a chain of commands here.
" :w saves the file.
" <CR> (carriage return) is like pressing the enter key.
" !clear runs the external clear screen command.
" !python3 % executes the current file with Python.
nnoremap <f5> :w <CR>:!clear <CR>:!python3 % <CR>

" You can split the window in Vim by typing :split or :vsplit.
" Navigate the split view easier by pressing CTRL+j, CTRL+k, CTRL+h, or CTRL+l.
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

" Resize split windows using arrow keys by pressing:
" CTRL+UP, CTRL+DOWN, CTRL+LEFT, or CTRL+RIGHT.
noremap <c-up> <c-w>+
noremap <c-down> <c-w>-
noremap <c-left> <c-w>>
noremap <c-right> <c-w><

" NERDTree specific mappings.
" Map the F3 key to toggle NERDTree open and close.
nnoremap <F3> :NERDTreeToggle<cr>

" Have nerdtree ignore certain files and directories.
let NERDTreeIgnore=['\.git$', '\.jpg$', '\.mp4$', '\.ogg$', '\.iso$', '\.pdf$', '\.pyc$', '\.odt$', '\.png$', '\.gif$', '\.db$']

" Use 'w!!' to save a file as root
cmap w!! w !sudo tee > /dev/null %

" }}}

" VIMSCRIPT -------------------------------------------------------------- {{{


" }}}

" STATUS LINE ------------------------------------------------------------ {{{

" Clear status line when vimrc is reloaded.
set statusline=

" Status line left side.
set statusline+=\ %F\ %M\ %Y\ %R

" Use a divider to separate the left side from the right side.
set statusline+=%=

" Status line right side.
"set statusline+=\ ascii:\ %b\ hex:\ 0x%B\ row:\ %l\ col:\ %c\ percent:\ %p%%

" Show the status on the second to last line.
set laststatus=2

" }}}
