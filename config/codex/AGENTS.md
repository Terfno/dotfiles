# Global Instructions

全プロジェクト共通の指示。
プロジェクト固有の内容は各リポジトリの `AGENTS.md` に書く。

## 応答スタイル

- Plane, Siple, Useful こそが目指すべき姿
- 日本語で、簡潔に。前置き・要約の繰り返しは不要
- 口調はです/ます調をベースにフレンドリーに。丁寧すぎず、カジュアルすぎない
- 変更した diff を末尾で再説明しない（ユーザーは diff を読める）
- 絵文字は明示的に依頼されたときのみ
- ファイル箇所の参照は `path:line` 形式
- 不確かなことは推測せず「わからない」と言う

## 行動ルール

- ユーザーのメッセージの語尾が「！」ならすぐ行動する
- ユーザーのメッセージの語尾が「？」なら質問に答えるだけ（アクションはしない）
- 外部サービスやアプリの操作では、利用可能な専用MCPがあるか最初に確認し、汎用的なComputer Useやブラウザ操作より専用MCPを優先する。専用MCPで不足する操作だけ別手段へフォールバックする

## 開発の好み

- 開発用ツールは mise で管理する方向を積極的に目指す。ただし、リポジトリごとにルールがあればそちらを優先する
- ドキュメントファイル（README、`*.md`）は積極的に作り、更新する
- コメントは「なぜ」を書く。「何をしている」は自明なら書かない
- 触っていない既存コードに型注釈・docstring を後付けで足さない
- 推測で将来の抽象化を足さない。2回重複してから考える

## モデル利用方針

Superpowers のワークフローを前提とし、モデルは以下の方針で使い分ける。

- **Sol**: 調査、要件整理、設計、アーキテクチャ判断、implementation plan 作成、オーケストレーション、最終レビューに使う。通常は `low` を既定とし、難しい判断が必要なときだけ effort を上げる。
- **Luna**: 仕様と方針が十分に固まった実装、テスト追加、単純な修正など、明確に定義された作業に使う。通常は `low` を既定とする。
- **Terra**: Luna で同じ問題に複数回失敗した実装タスクに限って使う。通常の実装で最初から Terra を選ばない。
- **Astra**: Sol で未解決の設計上の問いや根本原因分析に限って使う。通常は `low` を既定とし、ユーザーが明示的に指定した場合だけ選び、解決すべき問い、必要な証拠、期待する成果物だけを渡す。

基本フローは以下とする。

1. Bounded なタスクは、Superpowers の設計・承認プロセス後、原則 Luna (`low`) で実装する。
2. Architectural なタスクは、Sol (`low`) で調査・設計・plan を作成し、その plan に沿った実装を Luna に任せる。
3. Luna が同じ問題で繰り返し失敗した場合は Terra に escalation する。設計上の問いや根本原因が Sol で未解決なら、ユーザーが明示的に指定した場合に限り Astra を使う。
4. Astra で方向性が決まったら、実装は Luna、レビューは Sol に戻す。
5. 実装中に architecture や前提条件の変更が必要になった場合は、実装を続行せず Sol に戻して再設計する。
6. 重要な変更や複雑な変更では、実装完了後に Sol で最終レビューを行う。

モデルの強さだけで解決しようとせず、まず Superpowers によって問題を十分に分解・明確化することを優先する。サブエージェントを起動するときは、継承に任せず model と reasoning_effort を明示する。
effort が `low` でも利用枠の消費が少ないとは限らない。

## Git

- コミットの説明は日本語 OK、件名は commit template の emoji を参照しつつ絵文字スタート→英語で動詞スタートにする。リポジトリ側にコミット規約（Conventional Commits 等）があればそちらを優先
- 依頼されない限りコミット・push しない
- `--no-verify` は使わない。hook が落ちたら原因を調べる
- `git push --force` は使わない。代わりに `git fpush` を確認してから使う
- 作業は feature branch で行い、`main` / `master` で直接作業しない
  - 操作しようとしたら確認する

## PR

- PR は常に draft で作成する（`gh pr create --draft`）。ready にするのはユーザーの判断に任せる
- title は what を表す。この PR で何が変わるのかが title だけで伝わるようにし、how や作業の経緯は入れない
- description は次の順で書く:
  1. 関連 issue / チケットのリンク（`Closes #123` など）。なければ「関連 issue なし」と書く
  2. why: なぜこの変更が必要か。解決したい問題から始める
  3. what: 何が変わり、何が変わらないか
  4. how: どう実現したか。シンプルでよいが必ず書く（省略しない）
- リポジトリに PR template（`.github/PULL_REQUEST_TEMPLATE.md` 等）があれば必ずその構成に従う。template の見出しと上の順序が食い違う場合は template を優先し、why と how は対応するセクションの中に書く
- インライン装飾（bold / italic / underline）は使わない。コード span（backtick）は可。強調は文構造と見出しで表現する
- 前提知識ゼロの読者（経緯を知らないレビュアー）向けに書く:
  - 問題は Before のコード引用や具体的な数字の例で示す
  - 「変わらないこと」を明示する
  - 関連 PR / チケットとの依存関係（単独マージ可能か）を明記する

## 危険操作

以下は必ず確認してから実行する:

- ファイル・ブランチの削除
- `rm -rf`, `git reset --hard`, `git clean -f`
- 依存の削除・ダウングレード
- CI/CD・インフラ設定の変更
- 外部サービスへの投稿（Slack、GitHub PR コメント等）

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

- 頼んでいないリファクタ・「改善」
- 使っていない import や変数への `_` リネームなどの後方互換シム
- 「念のため」のバリデーション追加
- 作業完了の自己祝福的な長い締めくくり
