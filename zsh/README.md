# ZSH

After trying different environment managers such as oh-my-zsh, starship, and alike, I came to a conclusion that I
prefer to have a minimal and fast shell environment. I also don't need a lot of features that those managers provide,
and I want to have full control over my shell configuration. So I took my shell configuration and distilled it down to
the essentials, removing unnecessary features and plugins. I haven't touched it since then, so I believe it can be
stripped down even further. The goal is to have a fast and efficient shell environment that is easy to maintain and
customize.

Eventually, besides essentials `.zshrc` loads `./config/*.zsh.enabled` structured configuration files that can be
disabled by renaming them to `*.zsh.disabled`. This allows for easy customization and experimentation with different
configurations without having to modify the main `.zshrc` file.

Here is the list of enabled configuration files:

- `appearance.zsh.enabled` - Configures the appearance of the shell prompt and other visual elements.
- `completion.zsh.enabled` - Configures the shell's command completion behavior and settings.
- `directory.zsh.enabled` - Configures the behavior of the shell when navigating directories, including settings for
  the `cd` command and directory history.
- `git.zsh.enabled` - Configures Git-related settings and aliases for the shell.
- `history.zsh.enabled` - Configures the shell's command history behavior and settings.
- `kube-ps1.zsh.enabled` - Configures the shell's behavior when working with Kubernetes clusters, including settings for
  the `kubectl` command and related tools.
- `spectrum.zsh.enabled` - Configures the shell's behavior when working with the Spectrum color scheme, including
  settings for the prompt and other visual elements.
- `termsupport.zsh.enabled` - Configures the shell's behavior when working with terminal emulators and other
  terminal-related tools, including settings for terminal colors and key bindings.
- `misc.zsh.enabled` - Configures miscellaneous settings and aliases for the shell that don't fit into other categories.
- `zoxide.zsh.enabled` - Configures the shell's behavior when working with the Zoxide tool, including settings for

Configurations prefixed with `z` are overrides for specific tools and applications with less priority than the main
configuration files. They are loaded after the main configuration files:

- `zalias.zsh.enabled`
- `zeditcmdline.zsh.enabled`
- `zgit.zsh.enabled`
- `zkubectl.zsh.enabled`
- `ztheme.zsh.enabled`
