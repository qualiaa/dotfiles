" Vim default settings
source $VIMRUNTIME/defaults.vim

set rnu number

" ===========
" Plugins
" ===========

" -------------
" Vundle Setup
" -------------

" Vundle setup
filetype off

set rtp+=/home/jamie/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

" -------------
" Vundle Plugins
" -------------

" Git integration
Plugin 'tpope/vim-fugitive'

" Editing
Plugin 'scrooloose/nerdcommenter'
Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-surround'
Plugin 'godlygeek/tabular'
Plugin 'majutsushi/tagbar'


" Code completion and error reporting
Plugin 'scrooloose/syntastic'

" C/C++
Plugin 'a.vim'

" Webdev
Plugin 'ap/vim-css-color'
Plugin 'mattn/emmet-vim'

" Haxe
Plugin 'jdonaldson/vaxe'

" GLSL
Plugin 'glsl.vim'

" Plaintext and writing
"Plugin 'SpellChecker'
"Plugin 'coot/atp_vim'

" Python
Plugin 'nvie/vim-flake8'

" Appearance
Plugin 'powerline/powerline'
Plugin 'altercation/vim-colors-solarized'

call vundle#end()

filetype plugin indent on

" ----------------
" Plugin settings
" ----------------

" YouCompleteMe
let g:ycm_path_to_python_interpreter = '/usr/bin/python3'
let g:ycm_global_ycm_extra_conf = '~/.vim/ycm_extra_conf.py'
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_always_populate_location_list = 1
" let g:ycm_python_binary_path = "/usr/bin/python"

nnoremap gd :YcmCompleter GoToDeclaration<CR>
nnoremap gD :YcmCompleter GoToDefinition<CR>
" Note this somewhat supercedes a.vim
nnoremap gA :YcmCompleter GoToInclude<CR>
nnoremap <C-x> :YcmCompleter FixIt<CR>
nnoremap <C-t> :YcmCompleter GetTypeImprecise<CR>

" Powerline
set rtp+=/home/jamie/.vim/bundle/powerline/powerline/bindings/vim
set laststatus=2
set encoding=utf-8
set termencoding=utf-8
set term=xterm-256color
let g:Powerline_symbols = 'fancy'
" let g:Powerline_colorscheme = 'solarized256'

" Syntastic
let g:syntastic_error_symbol='✗'
let g:syntastic_warning_symbol='⚠'
" let g:syntastic_haskell_checkers=['ghc-mod.vim', 'hdevtools.vim']
let g:syntastic_cpp_checkers=['ycm']
let g:syntastic_python_checkers=['']
hi SignColumn cterm=NONE ctermbg=1 ctermfg=NONE
hi SyntasticWarningSign cterm=NONE ctermbg=1 ctermfg=yellow
hi SyntasticWarning cterm=NONE ctermbg=darkyellow ctermfg=NONE
hi SyntasticErrorSign cterm=NONE ctermbg=1 ctermfg=white
hi SyntasticError cterm=NONE ctermbg=darkred ctermfg=NONE





" ======================
" General Configuration
" ======================

" Stop ~ files
set nobackup

set autoindent

" Expand tabs to 4 spaces
set ts=4
set sts=4
set expandtab
set shiftwidth=4

" Set max width 80 chars
set textwidth=80
set colorcolumn=+1

" auto-reload vimrc on change
augroup myvimrc
    au!
    au BufWritePost .vimrc,_vimrc,vimrc,.gvimrc,_gvimrc,gvimrc so $MYVIMRC 
augroup END

" ------------
" Key settings
" ------------

" F1 clears trailing WS and saves
nmap <F1> :%s/\s\+$//e<CR>:w<CR>
" F2 toggles NERDTree
nmap <F2> :NERDTreeToggle<CR>
" F3 toggles tagbar
"nmap <F3> :TagbarToggle<CR>
" F4 opens vimrc
nnoremap <F4> :tabe ~/.vimrc<CR>
" F5 forces YCM diagnostics
" nnoremap <F5> :YcmForceCompileAndDiagnostics<CR>

" F7 toggles hlsearch
let hlstate=0
nnoremap <F7> :if (hlstate == 0) \| nohlsearch \| else \| set hlsearch \| endif \| let hlstate=1-hlstate<cr>

" Remove K key which nobody ever wants
nnoremap K k
vnoremap K k

" \z launches shell
nnoremap <Leader>z :terminal<CR>

" ----------------
" From example vimrc
" ----------------

" Put these in an autocmd group, so that we can delete them easily.
augroup vimrcEx
au!

" For all text files set 'textwidth' to 78 characters.
autocmd FileType text setlocal textwidth=78

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
" Also don't do it when the mark is in the first line, that is the default
" position when opening a file.
autocmd BufReadPost *
\ if line("'\"") > 1 && line("'\"") <= line("$") |
\ exe "normal! g`\"" |
\ endif

augroup END


" Add optional packages.
"
" The matchit plugin makes the % command work better, but it is not backwards
" compatible.
" The ! means the package won't be loaded right away but when plugins are
" loaded during initialization.
if has('syntax') && has('eval')
  packadd! matchit
endif





" ====================
" Appearance settings
" ====================

" Switch on highlighting the last used search pattern.
set hlsearch

" Relative numbering for current buffer
" Normal numbering for all other buffers
set number
augroup RelNo
    au!
    au VimEnter,WinEnter,BufWinEnter,FocusGained * setlocal rnu
    au WinLeave,FocusGained * setlocal nornu
augroup END

" Change window title to VIM - File
" TODO change to /file/path - vim
let &titlestring = hostname() . "[vim(" . expand("%:t") . ")]"
if &term == "screen"
    set t_ts=^[k
    set t_fs=^[\
endif
if &term == "screen" || &term == "xterm"
    set title
endif

" -----------
" Colours!
" -----------

if &t_Co > 2 || has("gui_running")
    syntax match TrailingWhiteSpace /[ \t]\+$/
    hi link TrailingWhiteSpace ErrorMsg

    hi Folded cterm=NONE ctermbg=11 ctermfg=8
    hi FoldColumn cterm=NONE ctermbg=black ctermfg=white
    hi CursorLine cterm=NONE ctermbg=NONE ctermfg=NONE
    hi ColorColumn cterm=NONE ctermbg=222 ctermfg=NONE
    hi VertSplit cterm=NONE ctermbg=white ctermfg=white
    hi Pmenu ctermfg=white ctermbg=5 guibg=LightMagenta
    hi Statement term=bold ctermfg=11 guifg=DarkCyan
    "hi TabLine cterm=NONE ctermbg=white ctermfg=248
    "hi TabLineSel cterm=NONE ctermbg=203 ctermfg=NONE "222
    "hi TabLineFill cterm=NONE ctermbg=white ctermfg=NONE

    " Solarized plugin
    set background=dark
    colorscheme solarized

    " Current Line Highlighting for current buffer
    augroup CursorLine
        au!
        au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
        au WinLeave * setlocal nocursorline
    augroup END

    syntax on
endif

highlight EndOfBuffer ctermfg=bg ctermbg=bg





" ============================
" Filetype Specific Settings
" ============================

" --------------
" ActionScript
" --------------

" formatting
augroup AS
    au!
    au BufEnter *.as set cindent
augroup END

" --------------
" GLSL
" --------------
"
augroup GLSL
    au!
    au BufNewFile,BufRead *.frag,*.vert,*.fp,*.vp,*.glsl setlocal cindent | setf glsl
augroup END

" --------------
" Haxe
" --------------

augroup Haxe
    au!
    au FileType haxe setlocal autowrite
    " au BufWritePost *.hx VaxeCtags
    au BufNewFile,BufRead /source/*.hx vaxe#ProjectLime("Project.xml")
augroup END
" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
    finish
endif

if &t_Co > 2 || has("gui_running")
    syntax match TrailingWhiteSpace /[ \t]\+$/
    hi link TrailingWhiteSpace ErrorMsg
endif
