---
name: sync-dotfiles-main
description: Use when the current machine's branch in Terfno/dotfiles needs to catch up to the latest shared default branch (main or master).
---

# 現在のマシン用ブランチを共有ブランチに追いつかせる

この手順は `Terfno/dotfiles` で、最新の共有ブランチを現在のマシン用ブランチへ取り込む場合だけ使います。ここでいう「main」は共有の統合ブランチを指し、実際の名前は `master` の場合もあります。ブランチ名、ホスト名、または main 以外という理由だけでマシン用と判断せず、用途が曖昧なら確認します。

## 事前確認

1. `git rev-parse --show-toplevel` で Git root を確認し、設定済み remote URL が SSH または HTTPS の `Terfno/dotfiles` と大文字小文字を区別せず一致することを確認します。フォルダー名では判定しません。リポジトリを特定できなければ停止します。
2. 現在のブランチが名前付きのマシン用ブランチであることを確認します。`main`、`master`、detached HEAD なら停止します。
3. `git status` 全体を確認します。merge、rebase、cherry-pick、revert、bisect の進行中、または unmerged paths があれば報告して停止します。
4. tracked / untracked を問わず作業ツリーに変更があれば、正確なパスを報告して停止します。自動で stash しません。

## 取り込み

1. ユーザーが取り込み元ブランチを明示した場合はその名前だけを使い、存在しなければ停止します。明示がなければ `git ls-remote --symref <remote> HEAD` でサーバーの default branch を調べ、`main` または `master` を使います。見つからない、または曖昧なら停止します。現在のブランチから共有ブランチを推測しません。
2. 明示的な refspec を使い、その remote branch だけを `refs/remotes/<remote>/<base>` に fetch します。失敗時は停止します。現在のブランチ、元の `HEAD`、base 名、fetch した SHA を記録し、以降は固定した SHA を使います。
3. 元の `HEAD` がすでに固定した base SHA を祖先に持つ場合は、最新であると報告して終了します。
4. 現在のブランチを保ち、merge ancestry を残します。rebase、reset、他ブランチへの checkout はしません。`git merge --no-commit --no-ff <pinned-base-SHA>` で確認可能な merge を開始し、merge commit を自動作成しません。
5. conflict が起きたら、利用可能であれば `resolve-git-conflicts` skill を使います。なければ base、ours、theirs を確認し、意図が明確な場合だけ共有側とマシン固有の動作を保って解決します。ours / theirs を自動選択せず、判断できなければ報告して停止します。

## 確認と報告

- conflict-free の pending merge では、現在のブランチが変わっておらず、`HEAD` が元のままであることを確認します。`MERGE_HEAD` が固定した base SHA と一致すること、`git diff --cached` の内容、unmerged paths がないことを確認し、`git diff --cached --check` と `git diff --check` を実行します。
- 変更されたファイルに合わせ、JSON / Ruby の構文確認またはリポジトリの適切なチェックを実行します。dotfile recipe の適用、ソフトウェアの install、マシン設定の変更はしません。
- pending merge の時点では base は `HEAD` の祖先ではありません。ユーザーの commit 待ちと報告し、依頼された場合に限り commit コマンドを案内します。commit 済み `HEAD` が固定した SHA を祖先に持つまでは同期完了としません。
- commit、push、ブランチ削除、deploy はしません。この skill は `.agents` 内に置き、dotfile や symlink の recipe は追加しません。
