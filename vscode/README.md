# VS Code Extensions

## Deprecated

It looks vscode extensions init is supported by `homebrew` and became a part of `Brewfile` dump.
Let's keep this list as a backup for a while.

## Export extensions

```shell
code --list-extensions > extensions.list
```

## Import extensions

```shell
cat extensions.list | xargs -I{} code --install-extension {}
```
