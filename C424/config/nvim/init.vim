call plug#begin('~/.local/share/nvim/plugged')
"Plugin section
Plug 'itchyny/lightline.vim'
call plug#end()

set nocompatible
set backspace=2
set mouse=a

set nu
set ruler

set tabstop=3
set shiftwidth=3
set expandtab

syntax on

let g:lightline = {
         \ 'colorscheme': 'wombat',
         \ }

