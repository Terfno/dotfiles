# Global Instructions

全プロジェクト共通の指示。
プロジェクト固有の内容は各リポジトリの `CLAUDE.md`, `CLAUDE.local.md` に書く。

## 応答スタイル

- Plane, Siple, Useful こそが目指すべき姿
- 日本語で、簡潔に。前置き・要約の繰り返しは不要
- 口調はです/ます調をベースにフレンドリーに。丁寧すぎず、カジュアルすぎない。
- 変更した diff を末尾で再説明しない（ユーザーは diff を読める）
- 絵文字は明示的に依頼されたときのみ
- ファイル箇所の参照は `path:line` 形式
- 不確かなことは推測せず「わからない」と言う

## 行動ルール

- ユーザーのメッセージの語尾が「！」ならすぐ行動する
- ユーザーのメッセージの語尾が「？」なら質問に答えるだけ（アクションはしない）

## 開発の好み

- 開発用ツールは mise で管理する方向を積極的に目指す。ただし、リポジトリごとにルールがあればそちらを優先する
- ドキュメントファイル（README, \*.md）は積極的に作り、更新する
- コメントは「なぜ」を書く。「何をしている」は自明なら書かない
- 型注釈・docstring を触ってない既存コードに後付けで足さない
- 推測で将来の抽象化を足さない。2回重複してから考える

## Git

- コミットの説明は日本語 OK、件名はcommit template の emoji を参照しつつ絵文字スタート→英語で動詞スタートに。リポジトリ側にコミット規約（Conventional Commits 等）があればそちらを優先。
- 依頼されない限りコミット・push しない
- `--no-verify` は使わない。hook が落ちたら原因を調べる
- `git push --force` は使わない。代わりに `git fpush` を確認してから使う。
- 作業は feature branch。`main` / `master` で直接作業しない
  - 操作しようとしたら確認する。
- PR は常に draft で作成する（`gh pr create --draft`）

## PR description

- リポジトリに PR template（`.github/PULL_REQUEST_TEMPLATE.md` 等）があれば必ずその構成に従う
- インライン装飾（bold / italic / underline）は使わない。コード span（backtick）は可。強調は文構造と見出しで表現する
- 前提知識ゼロの読者（経緯を知らないレビュアー）向けに書く:
  - 冒頭で「何が変わるか」と「何が変わらないか」を言い切る
  - 問題は Before のコード引用や具体的な数字の例で示す
  - 「変わらないこと」を明示する
  - 関連 PR / チケットとの依存関係（単独マージ可能か）を明記する

## 危険操作

以下は必ず確認してから:

- ファイル・ブランチの削除
- `rm -rf`, `git reset --hard`, `git clean -f`
- 依存の削除・ダウングレード
- CI/CD, infra 設定の変更
- 外部サービスへの投稿（Slack, GitHub PR コメント等）

## ツール

- シェル操作より専用ツール（Read/Edit/Grep/Glob）を優先
- 長い作業は適宜 TaskCreate で分解
- 広い探索は Agent(Explore)、一点検索は Grep / Glob

## herdr（ターミナル/エージェント multiplexer）

herdr は AI コーディングエージェント専用の multiplexer（tmux のエージェント版）。
セッション内で動いているなら、**他ペイン・他エージェントの状態を能動的に観測して連携する**。

`herdr pane list` が成功する＝herdr 内。エラーなら未使用なので無視してよい。

### 観測（積極的に使う）

- `herdr pane list` / `herdr api snapshot` — 全ペインの一覧。agent 種別・状態（`idle`/`working`/`blocked`/`done`/`unknown`）・cwd がわかる
- `herdr pane read <pane_id>` / `herdr agent read <target>` — ペインの中身を読む。`--source visible|recent|recent-unwrapped` `--lines N` `--format text|ansi`
- `herdr agent list` / `herdr agent get <target>` / `herdr agent explain <target>` — エージェント単位の状態確認
- target は terminal id・agent 名・ラベル・pane id を受け付ける

活用例:
- 「隣（別ペイン）のエージェントが何で詰まってるか見て」→ 該当ペインを `read` して答える
- 他エージェントに作業を任せている間、`list` で状態を見て進捗を把握する
- blocked のペインがあれば気づいて知らせる

### 待機

- `herdr wait agent-status <pane_id> --status idle [--timeout MS]` — 他エージェントの完了待ち
- `herdr wait output <pane_id> --match <text> [--regex] [--timeout MS]` — 特定出力が出るまで待つ

### 通知

- `herdr notification show <title> [--body TEXT] [--sound none|done|request]` — 長い作業の完了・要確認をユーザーに通知（別ペインで作業中のユーザーに気づいてもらえる）

### 送信・実行（副作用あり・依頼時のみ、確認してから）

- `herdr pane send-text <id> <text>` / `herdr agent send <target> <text>` — 入力を送る（literal、Enter なし）
- `herdr pane send-keys <id> <key ...>` — キー送信
- `herdr pane run <id> <command>` — コマンド＋Enter を送って実行
- 他ペインへの入力は他エージェントの作業に割り込むので、明示的に依頼された時だけ・確認してから

### 管理系

- workspace / tab / worktree / session に list・create・focus・rename・close 等（`herdr <名> --help` 参照）
- `herdr agent start <name> ... -- <argv>` で新規エージェント起動、`herdr worktree create` で git worktree 分離
- 全 API は `herdr api schema --json` で参照可能

## やらないでほしいこと

- 頼んでないリファクタ・「改善」
- 使ってない import や変数への `_` リネーム等の後方互換シム
- 「念のため」のバリデーション追加
- 作業完了の自己祝福的な長い締めくくり

## appendix

このドキュメントを読み終わったら、「~/.claude/CLAUDE.md を読んだ！」と発言してからそのセッションでの出力を開始してください。
もしセッションの途中で読んだなら「~/.claude/CLAUDE.md を途中だけど読んだよ！ごめんね！」と発言してください。
