" Some ideas taken from https://medium.com/hackernoon/clife-or-my-development-setup-67868b86cb57

" Specify a directory for plugins: ~/.local/share/nvim/plugged
if ! filereadable(expand('~/.config/nvim/autoload/plug.vim'))
	echo "Downloading junegunn/vim-plug to manage plugins..."
	silent !mkdir -p ~/.config/nvim/autoload/
	silent !curl "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" > ~/.config/nvim/autoload/plug.vim
	autocmd VimEnter * PlugInstall
endif

call plug#begin('~/.local/share/nvim/plugged')

" Airline is a plugin that makes the status line look fancier.
" It requires a custom font (with arrows), and is completely optional
" Plug 'vim-airline/vim-airline'
" Plug 'vim-airline/vim-airline-themes'

" A more convenient (than default) directory browser for Vim
Plug 'scrooloose/nerdtree'

" This is a core plugin to support autocompletion for most of the things.
" This is also the messiest one, as it requires manual (and periodic)
" invocation of the build script.
" Plug 'Valloric/YouCompleteMe'

" Autocompletion for Python
Plug 'davidhalter/jedi-vim'

" Highlights new/mofified/deleted lines in the "gutter"
Plug 'airblade/vim-gitgutter'

" Later in the config I'll bind this plugin to "gc"
" Typing "gc" will comment out a block or line of code in any language
Plug 'tpope/vim-commentary'

" A Git plugin with a crazy useful command :GitBlame
" Don't wait, blame someone else!
Plug 'tpope/vim-fugitive'

" A collection of colorschemes
Plug 'flazz/vim-colorschemes'
" Plug 'joshdick/onedark.vim'

" If you prefer Ctrl+h/j/k/l for navigating across vim/tmux splits,
" this plugin will integrate Vim and Tmux, so that you can seamlessly
" Jump across the border of a vim/tmux split
Plug 'christoomey/vim-tmux-navigator'

" This is the interesting one: it generates a Tmux config that makes
" a tmux status line look like a vim airline with an applied theme
Plug 'edkolev/tmuxline.vim'

" A wrapper around silversearcher-ag
" Plug 'rking/ag.vim'

" A Vim plugin for all things Go. Supports autocompletion,
" smart code navigation, linting, and much more
" Plug 'fatih/vim-go'

" Never got used to this one, but it allows for wrapping a piece of
" text into "", '', or custom tags
Plug 'tpope/vim-surround'

" Fzf for ffffuzzzy search~
" Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" Neomake for asynchronous linting and building
" Plug 'neomake/neomake'

" A beautiful autopep8. Have it bound to "ap"
Plug 'tell-k/vim-autopep8'

" Import sorter for Python
Plug 'fisadev/vim-isort'

" Initialize plugin system
call plug#end()

set updatetime=500

" Neomake configs to make it a bit less annoying

" When writing a buffer.
" call neomake#configure#automake('w')
" When writing a buffer, and on normal mode changes (after 750ms).
" call neomake#configure#automake('nw', 750)
" When reading a buffer (after 1s), and when writing.
" call neomake#configure#automake('rw', 1000)
" let g:neomake_open_list = 2

" Airline setup

" set laststatus=2
" let g:airline_powerline_fonts = 0
" let g:airline_theme = "jellybeans"

" Jedi-vim configuration
let g:jedi#show_call_signatures = 1
let g:jedi#popup_select_first = 0
let g:jedi#completions_enabled = 0
autocmd FileType python setlocal completeopt-=preview


set encoding=utf-8
" Turn on line numbers
set number relativenumber
" Turn on syntax highlighting
syntax on
" It hides buffers instead of closing them.
" https://medium.com/usevim/vim-101-set-hidden-f78800142855
set hidden
" Highlights search results as you type vs after you press Enter
set incsearch
" Ignore case when searching
set ignorecase
set smartcase
" Turns search highlighting on
set hlsearch
" Turn on TrueColor
set termguicolors
" Disables automatic commenting on newline:
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
" Splits open at the bottom and right, which is non-retarded, unlike vim defaults.
set splitbelow splitright
" Automatically deletes all trailing whitespace on save.
autocmd BufWritePre * %s/\s\+$//e

" Tabs and Indents
" ----------------
set textwidth=80    " Text width maximum chars before wrapping
set expandtab       " Expands tabs into spaces
set tabstop=2       " The number of spaces a tab is
set softtabstop=2   " While performing editing operations
set shiftwidth=2    " Number of spaces to use in auto(indent)
set smarttab        " Tab insert blanks according to 'shiftwidth'
set autoindent      " Use same indenting on new lines
set smartindent     " Smart autoindenting on new lines
set shiftround      " Round indent to multiple of 'shiftwidth'


" Wildmenu {{{
" --------
if has('wildmenu')
    set nowildmenu
    set wildmode=list:longest,full
    set wildoptions=tagfile
    set wildignorecase
    set wildignore+=.git,.hg,.svn,.stversions,*.pyc,*.swp,*.bak,*.class,*.spl,*.o,*.out,*~,%*
    set wildignore+=*.jpg,*.jpeg,*.png,*.gif,*.zip,**/tmp/**,*.DS_Store
    set wildignore+=**/node_modules/**,**/bower_modules/**,*/.sass-cache/*
    set wildignore+=application/vendor/**,**/vendor/ckeditor/**,media/vendor/**
    set wildignore+=__pycache__,*.egg-info
endif


if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s -l --nocolor --ignore .git --ignore build-out --ignore build-opt --ignore build-dbg -g ""'

endif

" This colorscheme mimics a default Atom colorscheme which I quite like
colorscheme molokai

" Ctrl+P opens a fuzzy filesearch window (powered by Fzf)
nnoremap <C-p> :Files<CR>


" Switch to last active tab
let g:lasttab = 1
" I really like tt for switching between recent tabs
nmap tt :exe "tabn ".g:lasttab<CR>
au TabLeave * let g:lasttab = tabpagenr()

" A bit of autopep8 config
let g:autopep8_disable_show_diff=1
" ap for a quick .py file formatting
nnoremap ap  :Autopep8<CR>
" This is a quick way to call search-and-replace on a current word
nnoremap <Leader>s :%s/\<<C-r><C-w>\>//g<Left><Left>
" cc now hides those annoying search highlihghts after you're done searching
nnoremap cc :let @/ = ""<cr>
" \e to open a NerdTree at in the directory of the currently viewed file
nnoremap <Leader>e :Ex<CR>
" I said write it!
cmap w!! w !sudo tee % >/dev/null
