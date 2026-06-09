# opencode config

```sh
brew install jsonnet
./render-config.sh
```

## ollama

ollama のモデル一覧を opencode の設定に同期する:

```sh
./sync-ollama.sh
```

`ollama list` をパースし、`ollama.libsonnet` を生成してから `opencode.json` まで自動生成する。
モデルの属性は命名規則で自動判定する:

| モデル名のパターン | reasoning |
|---|---|
| `deepseek-r1`, `qwq`, `*:thinking`, `reasoning-*` | `true` |
| 上記以外 | `false` |

`tool_call` は全モデル `true`。

## cookpad

`template.ckpd.libsonnet` を `ckpd.libsonnet` にリネームして編集する:

```sh
cp template.ckpd.libsonnet ckpd.libsonnet
```

`render-config.sh` は `ckpd.libsonnet` があれば `provider` に merge し、無ければ `base.jsonnet` だけを元に `opencode.json` を出力する。
