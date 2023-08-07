# Krew

Dump:

```shell
kubectl krew list | tee Krewfile
```

Restore:

```shell
cat Krewfile | xargs kubectl krew install
```
