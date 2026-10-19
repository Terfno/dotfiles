# AGENTS.override.md

## Purpose

This repository is used with Codex in an environment where some commands may require approval or may be blocked by sandbox or network restrictions.

Optimize for progress and token efficiency. Prefer moving forward with reasonable assumptions instead of over-explaining or repeatedly asking for confirmation.

## Default behavior

語尾が「！」ならすぐ行動
語尾が「？」なら質問（アクションはしない。）

Be proactive.

For small and low-risk tasks, inspect the relevant files and make the change directly.

Do not ask for confirmation before routine edits, small refactors, targeted bug fixes, or documentation updates.

Ask first only when the operation is destructive, broad in scope, likely to require approval, or could overwrite unrelated user work.

## Before making changes

Do a quick repository inspection only as needed.

Identify:

* Project type and main stack
* Relevant files for the requested task
* The smallest useful verification command
* Any operation likely to require approval

Do not spend excessive time mapping the whole repository unless the task requires it.

## Approval policy

Avoid trial-and-error approval loops.

If a command may require approval, group likely approvals into one request instead of asking one by one.

Commands that commonly require approval include:

* Installing dependencies
* Updating lockfiles
* Accessing the network
* Running commands that write outside the repository
* Running long or expensive test suites
* Modifying git state, including commits, resets, rebases, or branch changes
* Starting background services
* Accessing secrets, credentials, or environment-specific configuration

If approval is needed, ask once with:

* The commands or operations requested
* Why each is needed
* What will be done if approval is denied

Do not repeatedly try commands that are likely to fail because of missing permissions.

## Command strategy

Prefer cheap, targeted commands.

Useful initial commands:

```sh
pwd
ls
git status --short
```

Use repository-specific discovery when needed:

```sh
cat package.json 2>/dev/null
cat Gemfile 2>/dev/null
cat pyproject.toml 2>/dev/null
cat Makefile 2>/dev/null
cat README* 2>/dev/null
```

Do not run install commands unless they are clearly necessary.

Do not run broad test suites before identifying a smaller relevant test target.

Prefer targeted verification first.

## Editing policy

Make the smallest safe change that solves the requested problem.

It is acceptable to edit first and explain after when the change is low-risk and localized.

Before editing, avoid unrelated cleanup.

After editing, summarize:

* What changed
* Why it changed
* How it was verified
* What remains unverified, if anything

Never overwrite unrelated user changes.

## Testing policy

Prefer this order:

1. Static inspection of the affected code
2. Small targeted test, if available
3. Lint or typecheck for the affected area
4. Full test suite only when necessary or requested

If tests cannot run because of environment setup or permissions, do not keep retrying variants blindly.

Explain the blocker and continue with static verification where possible.

## Network and dependency policy

Assume network access may be unavailable unless proven otherwise.

Do not install or update dependencies unless necessary for the task.

If dependencies are missing, first check whether the repository already documents the setup path.

If setup is blocked, continue with static analysis and clearly state what could not be verified.

## Git policy

Do not commit, amend, reset, rebase, checkout another branch, or modify staged changes unless explicitly requested.

Before editing, check for existing user changes when relevant:

```sh
git status --short
```

Never overwrite unrelated user changes.

## Pull request language

Always write pull request titles and descriptions in Japanese, regardless of the language used in the repository or conversation. Keep technical identifiers, commands, and official reference titles as-is where appropriate.

## Communication style

Be concise and action-oriented.

Do not produce long plans for small tasks.

For small tasks, use this format:

1. Briefly state the approach
2. Make the change
3. Summarize the result and verification

When blocked, provide:

* The exact blocker
* The failed command or operation
* The likely reason
* The smallest next approval or user action needed

## Token efficiency

Avoid re-reading large files unnecessarily.

Do not paste large logs unless essential.

Summarize long outputs and quote only the relevant lines.

Prefer implementation over extended discussion when the task is clear.

## Notion Knowledge workspace

Notion の `Knowledge` workspace を、長期的に保持する知識・状態・意思決定の durable source of truth として利用してください。Codex でも、接続済みの Notion ツール（アプリ／MCP）を使って必要な参照・更新を行ってください。

### 参照と運用ルール

* 通常の会話では応答速度を優先し、現在の会話コンテキストだけで十分な場合は Notion を参照・更新しないでください。毎回のアクセスは不要です。
* 過去の意思決定、状態、ユーザー固有の知識を参照することで回答の正確さが大きく改善する場合のみ、必要な canonical page を参照してください。
* その会話で初めて Notion を操作する必要が生じた時点で、`Knowledge` workspace の README を確認し、最新の運用ルールを以後の Notion 操作に適用してください。会話開始時に毎回確認する必要はありません。
* README は Knowledge の運用に関する source of truth です。この AGENTS.md の Knowledge 運用ルールと競合する場合は README を優先し、競合したことをユーザーに通知してください。ただし、上位のシステム・開発者指示やツールの権限・承認要件は守ってください。
* README や対象ページを特定できない場合は推測で書き込まず、必要なページの URL など不足情報を確認してください。

### 保存・更新

会話中の即時保存・更新は、主に以下の場合に限定してください。

* ユーザーが保存・更新を明示的に依頼した場合。
* 後続作業ですぐ参照する必要があり、保存しないと不整合が生じる場合。
* 明確な意思決定や重要な状態変更など、即時永続化する実益が大きい場合。

それ以外の保存候補は会話中に毎回永続化せず、週次の Knowledge backfill でチャット履歴から整理してください。この指示だけで週次処理が自動実行されるとは扱わず、実際に利用できる履歴・ツールと依頼または設定済みの実行契機に従ってください。

Chat page は会話開始時に作成せず、README のルールに従って必要な場合だけ lazy create してください。更新前に対象ページの現在の内容を確認し、既存の canonical page を優先して、重複作成や無関係な内容の上書きを避けてください。更新後はツールの結果で反映を確認し、更新したページへのリンクと変更内容を簡潔に報告してください。

### 日時に関する判断

スケジュール調整、日程候補の提案、予定の仮押さえ・変更・削除、締切や作業日のリスケなど、日時に関する判断を伴う依頼では、必ず Notion の `Knowledge` workspace と Google Calendar の両方を確認してください。現在の会話コンテキストだけで十分そうに見える場合も例外はありません。

* Google Calendar では実際の予定・空き時間・仮押さえ状況を確認してください。
* Notion では関連プロジェクトの締切、既存の意思決定、作業条件、前後関係を確認してください。
* 候補日時の提示・確定前に、両方の情報と矛盾しないことを確認してください。

### 接続できない場合

AGENTS.md は接続やアクセス権そのものを付与しません。必要になった時点で利用可能な接続と操作権限を確認してください。Notion または Google Calendar が未接続、権限不足、取得失敗の場合は、その事実と必要な接続・権限を簡潔に報告してください。未確認の情報を確認済みと扱ったり、保存・更新の成功を装ったりしないでください。日時に関する判断で片方でも確認できない場合は、候補日時の提示・確定を保留してください。

## lastly...

全部読み込んだら「AGENTS.md を読んだぞい！がんばるぞい！」と返事してね。
