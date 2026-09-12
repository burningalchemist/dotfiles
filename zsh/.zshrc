# --- User configuration
## Editor
export EDITOR=nvim
## Manpages
export MANPAGER="less -R --use-color -Dd+g -Du+y"
# GPG Terminal Pinentry
export GPG_TTY=$(tty)
## Common Tokens
source "/Users/username/.secrets"
## Language
# export LANG=en_US.UTF-8

## --- ZSH Completions
# Load and initialize the completion system ignoring insecure directories with a cache time of 20 hours, so it should
# almost always regenerate the first time a shell is opened each day.
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

# --- Apps
# ## Kubernetes configuration
# export KUBECONFIG=$HOME/.kube/config:$HOME/.kube/config_kind
#
# ## Kubernetes Prompt
# PROMPT='$(kube_ps1)'$PROMPT
# KUBE_PS1_ENABLED=off
# KUBE_PS1_SYMBOL_DEFAULT=k8s
# KUBE_PS1_SYMBOL_ENABLE=false
#
# ## Kubernetes Krew
# export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

## Fzf
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git -d 3'
source ~/.fzf.zsh

## .local/bin PATH
export PATH="$HOME/.local/bin:$PATH"

# ## Postgres CLIs
# export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# --- Programming Languages
## Golang
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# ## NodeJS/pnpm (removed pnpm until they stop installing stuff via pnpx without asking)
# export PNPM_HOME="/Users/sergei/Library/pnpm"
# export PATH="$PNPM_HOME:$PATH"

# Zig
export PATH="/Users/sergei/Downloads/zig-0.16.0/zls:$PATH"
export PATH="$PATH:/Users/sergei/Downloads/zig-0.16.0"

# Haskell
export PATH="$HOME/.cabal/bin:$HOME/.ghcup/bin:$PATH"

# Java with jabba and zulu
export PATH="$HOME/.jabba/jdk/zulu@1.17.0-13/Contents/Home/bin:$PATH"

# Rust
export PATH="/opt/homebrew/opt/rustup/bin:$PATH"

# ## NVM (Node Version Manager) (It's disabled by default with --no-use - run `nvm use default` or `nvm use <version>` in
# # a shell to enable it). 
# Currently disabled as there is no need for multiple node versions.
# export NVM_DIR="$HOME/.nvm"
#  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh" --no-use
#  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/sergei/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/sergei/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '/Users/sergei/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/sergei/google-cloud-sdk/completion.zsh.inc'; fi

# --- Last mile config
alias docker="podman"
alias :q="exit"
#alias ls="lsr"
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
# No unexpected npx installs, only run npx commands that are already installed globally or locally in the project. This
# prevents accidental downloads of packages from the internet when running npx commands.
alias npx="npx --no"
# Typo fix for clear
alias claer="clear"
# Remove subshell from mc to avoid issues with terminal resizing and other problems like startup freeze.
alias mc="mc --nosubshell"
