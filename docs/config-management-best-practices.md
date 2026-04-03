# Config Management Best Practices

現時点での dotfiles 管理方針メモ。後で見直す前提のたたき台。

## 前提

- ツールによっては `foo.local.json` や `include` / `extends` のような分割手段を持つ
- ツールによっては単一ファイルしか読めず、部分管理が難しい
- `~/.config/...` の実ファイルを直接編集し、その変更を dotfiles に持ち帰れる運用は便利

## 基本方針

- まずは「ファイル単位で管理できるか」を優先する
- 無理なら「部分的に持ち帰る範囲を固定した partial sync」にする
- それもつらいなら unmanaged にする
- 無理に全ツールを同じモデルで扱わない

## 管理モード

### 1. Whole-file managed

もっとも扱いやすい形。

- dotfiles 側が実質 SSOT
- 実ファイルは symlink, template, apply などで配置する
- live file first をやるなら、実ファイルを編集したあと dotfiles 側へ取り込む導線を用意する

向いているケース:

- 設定全体を自分でコントロールしたい
- ツールがファイルを勝手に大きく書き換えない
- ローカル差分を host 条件分岐や template で吸収できる

### 2. Partial-sync managed

単一ファイルしか読めず、一部だけを持ち帰りたいときの現実解。

- 実ファイル `~/.config/...` を普段の編集対象にする
- dotfiles 側には managed subset だけ保存する
- `sync` と `apply` を明示コマンドに分ける
- 自動双方向同期は目指さない

向いているケース:

- 一部のキーだけ再現できればよい
- ツール固有のノイズやローカル専用値を残したい
- local override の仕組みがない

実装イメージ:

- `sync-foo`: 実ファイルから managed keys を抽出して dotfiles に保存
- `apply-foo`: dotfiles 内の managed keys を実ファイルへ merge
- SSOT は完成ファイルではなく partial config または patch

### 3. Unmanaged

追いかけない方がよいものもある。

- ツールが頻繁に自動更新する
- 構造が不安定
- 手で持ち帰るコストに対して価値が低い

## 部分管理のベストプラクティス

- 可能なら部分管理よりファイル分割を優先する
- 分割できないなら managed keys を固定する
- managed / unmanaged の境界を曖昧にしない
- SSOT は「完成ファイル」ではなく「partial config」か「patch」に置く
- 部分管理で live file first をやるなら、リアルタイム同期ではなく明示コマンドにする

## live file first との折り合い

`~/.config/opencode/opencode.json` のような実ファイルを直接編集し、その変更を dotfiles に反映したい、という考え方自体はよい。ただし部分管理では、次を受け入れる必要がある。

- 実ファイル全体をそのまま SSOT にはしない
- dotfiles 側に持ち帰る範囲は限定する
- 同期は `sync` / `apply` の明示操作にする

つまり、次の切り分けになる。

- whole-file managed: 実ファイルと dotfiles をほぼ同一視できる
- partial-sync managed: 実ファイルが本体、dotfiles は持ち帰る断面

## フォーマッタ設定の扱い

`lefthook.yml` と `package.json` のように、対象ファイルと実行方法を複数箇所で持つのは避けたい。

ただし `lefthook` の `parallel` を活かしたいなら、1 本の実行スクリプトに全寄せするのはやや不利。

現時点の考え:

- SSOT を「フォーマッタ定義データ」に置く
- `lefthook.yml` と `package.json` はそこから生成する
- `lefthook` では formatter ごとに command を分け、`parallel: true` を活かす

## 運用ルール案

- 新しい設定ファイルを管理するときは、まず whole-file managed にできるか考える
- できない場合だけ partial-sync managed を選ぶ
- partial-sync managed にしたら、managed keys と sync/apply コマンドを固定する
- 価値が低いものは unmanaged のままにする

## 現時点の結論

- ベストプラクティスは 1 つではなく、ツールの性質ごとに管理モードを分けること
- 可能なら whole-file managed
- 無理なら partial-sync managed
- それもコストに見合わなければ unmanaged

後で見直すときは、特に次を再検討する。

- partial-sync managed をどこまで許容するか
- live file first をどのツールまで適用するか
- フォーマッタ定義の生成運用を入れるか
