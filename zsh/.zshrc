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
# source "/Users/sergei/.secrets"


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
export PATH="/Users/sergei/zls:$PATH"
export PATH="$PATH:/Users/sergei/Downloads/zig-0.11.0"
