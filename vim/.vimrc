syntax on
set number
set ruler
set list
set listchars=tab:▒░,trail:▓,nbsp:░

au OptionSet number :if v:option_new | set showbreak= |
                   \ else | set showbreak=↪ |
                   \ endif

"set mouse+=a"
