# opencode config

```sh
brew install jsonnet
./render-config.sh
```

## ollama

```sh
curl -fsSL https://ollama.com/install.sh | sh
```

```sh
ollama pull gpt-oss:20b
```

tempalte.ckpd.libsonnet を `ckpd.libsonnet` にリネームして、編集する。

```sh
cp template.ckpd.libsonnet ckpd.libsonnet
```

```sh
render-config.sh
```

↑は`ckpd.libsonnet` があれば `provider` に merge して `opencode.json` を生成し、無ければ `base.jsonnet` だけを元に `opencode.json` 出力する。
