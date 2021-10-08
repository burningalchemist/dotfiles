set encoding=utf-8
scriptencoding utf-8
syntax on
set number
set ruler
set list
set listchars=tab:▒░,trail:▓,nbsp:░
set rtp+=/usr/local/opt/fzf

au OptionSet number :if v:option_new | set showbreak= |
                   \ else | set showbreak=↪ |
                   \ endif

"set mouse+=a"

set showcmd
set hlsearch
set showmatch
set ignorecase
set smartcase

set scrolloff=3
set ai
set rtp+=/usr/local/opt/fzf
