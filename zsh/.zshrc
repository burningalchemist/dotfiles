# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/sergei/.oh-my-zsh"

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
#ZSH_THEME="spaceship"
ZSH_THEME="simple"

# Set list of themes to load
# Setting this variable when ZSH_THEME=random
# cause zsh load theme from this variable instead of
# looking in ~/.oh-my-zsh/themes/
# An empty array have no effect
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  kube-ps1
)

# Plugin list
# kube-ps1 - enabled

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Kubernetes Prompt
PROMPT='$(kube_ps1)'$PROMPT
KUBE_PS1_ENABLED=off
KUBE_PS1_SYMBOL_DEFAULT=k8s
KUBE_PS1_SYMBOL_ENABLE=false

# Editor
export EDITOR=nvim

# Aliases
alias kubectx="kubectl ctx"
alias kubens="kubectl ns"
alias pip="pip3.11"
alias vim="nvim"
alias k="kubectl"
alias watch='watch '
alias imgcat="wezterm imgcat"
alias vimdiff="nvim -d"

# ZSH Completions
autoload -U compinit && compinit -u

# Kubernetes configuration
export KUBECONFIG=$HOME/.kube/config:$HOME/.kube/config_kind
source <(kubectl completion zsh)

# Fzf
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git -d 3'
source ~/.fzf.zsh

# Kubernetes Krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# Golang
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# Python third-party binaries
# Native MacOS Python (not good)
# export PATH="/Users/sergei/Library/Python/3.9/bin:$PATH"

# Python 3 (Paths seem obsolete)
# export PATH="/usr/local/opt/python@3.10/bin:$PATH"
# export PATH="/Users/sergei/Library/Python/3.11/bin:$PATH"

# Java
# export JAVA_HOME=`/usr/libexec/java_home -v 14`

# Haskell
# export PATH="/Users/sergei/.local/bin:$PATH"

# LibreSSL
# export PATH="/usr/local/opt/libressl/bin:$PATH"

# Tokens
# source "/Users/sergei/.secrets"

# ArgoCD
# source <(argocd completion zsh)

# pnpm
export PNPM_HOME="/Users/sergei/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# Zig
export PATH="/Users/sergei/zls:$PATH"
export PATH="$PATH:/Users/sergei/Downloads/zig-0.11.0"

# Jira CLI
# source <(jira completion zsh)

# Zoxide
# eval "$(zoxide init zsh)"
