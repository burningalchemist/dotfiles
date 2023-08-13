# --- Bootstrap base zsh configuration
for file in ~/.config/zsh/*.zsh.enabled; do
    source "$file"
done

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
autoload -U compinit && compinit -u

## Kubernetes configuration
export KUBECONFIG=$HOME/.kube/config:$HOME/.kube/config_kind
source <(kubectl completion zsh)

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

## Jira CLI
# source <(jira completion zsh)

## ArgoCD
#source <(argocd completion zsh)

## Zoxide
eval "$(zoxide init zsh)"

# --- Programming Languages
## Golang
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

## Python 3 (Paths seem obsolete)
# export PATH="/usr/local/opt/python@3.10/bin:$PATH"
# export PATH="/Users/sergei/Library/Python/3.10/bin:$PATH"

## Haskell
# export PATH="/Users/sergei/.local/bin:$PATH"

## NodeJS/pnpm
export PNPM_HOME="/Users/sergei/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# Zig
export PATH="/Users/sergei/zls:$PATH"
export PATH="$PATH:/Users/sergei/Downloads/zig-0.11.0"
