# VS Code Extensions

## Export extensions

```shell
code --list-extensions > extensions.list
```

## Import extensions

```shell
cat extensions.list | xargs -I{} code --install-extension {}
```
