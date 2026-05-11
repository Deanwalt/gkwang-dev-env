call plug#begin()

" List your plugins here
Plug 'tpope/vim-sensible'
Plug 'airblade/vim-gitgutter'
Plug 'zivyangll/git-blame.vim'

call plug#end()


nnoremap ,s :<C-u>call gitblame#echo()<CR>
