set number
" set relativenumber
set cursorline
set ruler
set list
set listchars=tab:▒░,trail:▓,nbsp:░

au OptionSet number :if v:option_new | set showbreak= |
                   \ else | set showbreak=↪ |
                   \ endif

syntax off


set showcmd
set hlsearch
set showmatch
set ignorecase
set smartcase

set scrolloff=3

filetype indent on
filetype plugin indent on

set mouse+=a
set rtp+=~/.fzf

" new flags
"colorscheme elflord
set title
set inccommand=split
set splitbelow splitright
set expandtab
set wildmenu

" shortcuts
nnoremap <S-t> :tabnew<CR>

call plug#begin()

" Any valid git URL is allowed
" Plug 'junegunn/vim-github-dashboard', { 'on': ['GHDashboard', 'GHActivity'] }

" Plugin outside ~/.vim/plugged with post-update hook
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim'
Plug 'preservim/nerdtree'
Plug 'airblade/vim-gitgutter'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }

" Initialize plugin system
call plug#end()

function! TreeSitterConfig()
lua << EOF
require'nvim-treesitter.configs'.setup {
  -- One of "all", "maintained" (parsers with maintainers), or a list of languages
  ensure_installed = {"yaml", "hcl", "terraform", "dockerfile"},

  -- Install languages synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- List of parsers to ignore installing
  ignore_install = { "javascript" },

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    -- list of language that will be disabled
    disable = { "c", "rust" },

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },

  indent = {
    disable = { 'yaml' }
  }
}
EOF
endfunction

call TreeSitterConfig()

" Fix weird yaml indent shifts
autocmd FileType yaml setlocal indentexpr=

" NerdTree
let NERDTreeShowHidden=1

" Folding
set foldmethod=expr
set foldlevelstart=20
set foldexpr=nvim_treesitter#foldexpr()
