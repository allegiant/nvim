let path='~/.vim/bundle'

call plug#begin(path)

Plug 'sainnhe/gruvbox-material'
Plug 'scrooloose/nerdtree'
Plug 'itchyny/lightline.vim'
Plug 'mengelbrecht/lightline-bufferline'

Plug 'ryanoasis/vim-devicons'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'      """""""""""webdev图标
Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension' }
Plug 'liuchengxu/vim-which-key'
Plug 'tpope/vim-commentary'
" Plug 'LunarWatcher/auto-pairs'
Plug 'voldikss/vim-floaterm'
Plug 'airblade/vim-gitgutter'

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'yaegassy/coc-volar', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-json', {'do': 'yarn install --frozen-lockfile'}
Plug 'fannheyward/coc-marketplace', {'do': 'yarn install --frozen-lockfile'}
Plug 'iamcco/coc-vimlsp', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-snippets', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-pairs', {'do': 'yarn install --frozen-lockfile'}



call plug#end()

IncScript core/config/NERDTree.vim
IncScript core/config/lightline.vim
IncScript core/config/leaderf.vim
IncScript core/config/floaterm.vim
IncScript core/config/gitgutter.vim
IncScript core/config/coc.vim

