# --- User configuration
## Editor
export EDITOR=nvim

## Manpages
# export MANPATH="/usr/local/man:$MANPATH"

## Language
# export LANG=en_US.UTF-8

## ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

## --- ZSH Completions
# Load and initialize the completion system ignoring insecure directories with a
# cache time of 20 hours, so it should almost always regenerate the first time a
# shell is opened each day.
autoload -Uz compinit
_comp_files=(${ZDOTDIR:-$HOME}/.zcompdump(Nm-20))
if (( $#_comp_files )); then
  compinit -i -C
else
  compinit -i
fi
unset _comp_files

# --- Bootstrap base zsh configuration
for file in ~/.config/zsh/*.zsh.enabled; do
    source "$file"
done

## Kubernetes configuration
export KUBECONFIG=$HOME/.kube/config:$HOME/.kube/config_kind

## Kubernetes Prompt
PROMPT='$(kube_ps1)'$PROMPT
KUBE_PS1_ENABLED=off
KUBE_PS1_SYMBOL_DEFAULT=k8s
KUBE_PS1_SYMBOL_ENABLE=false

## Kubernetes Krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# --- Misc
## Common Tokens
source "/Users/sergei/.secrets"

# --- Apps
## Fzf
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git -d 3'
source ~/.fzf.zsh

# --- Programming Languages
## Golang
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

## NodeJS/pnpm
export PNPM_HOME="/Users/sergei/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# Zig
export PATH="/Users/sergei/Downloads/zig-0.16.0/zls:$PATH"
export PATH="$PATH:/Users/sergei/Downloads/zig-0.16.0"

# Haskell
export PATH="$HOME/.cabal/bin:$HOME/.ghcup/bin:$PATH"

# Java with jabba and zulu
export PATH="$HOME/.jabba/jdk/zulu@1.17.0-13/Contents/Home/bin:$PATH"

# .local/bin PATH
export PATH="$HOME/.local/bin:$PATH"

# Rust
export PATH="/opt/homebrew/opt/rustup/bin:$PATH"

# GPG Terminal Pinentry
export GPG_TTY=$(tty)

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/sergei/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/sergei/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/sergei/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/sergei/google-cloud-sdk/completion.zsh.inc'; fi

# Postgres CLIs
# export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# --- Last mile config
alias docker="podman"
alias :q="exit"
#alias ls="lsr"

# No unexpected npx installs, only run npx commands that are already installed globally or locally in the project. This prevents accidental downloads of packages from the internet when running npx commands.
alias npx="npx --no"
# Typo fix for clear
alias claer="clear"

export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
