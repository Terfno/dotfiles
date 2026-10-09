---
name: resolve-git-conflicts
description: Resolve Git merge, cherry-pick, and interactive-rebase conflicts safely. Use when Git reports unmerged paths, conflict markers, a paused rebase, or when reconciling divergent code changes requires preserving intent rather than blindly choosing one side.
---

# Resolve Git Conflicts

Inspect the repository before editing. Preserve unrelated working-tree changes and explain the resolution rationale succinctly.

## Workflow

1. Determine the operation and conflict set.

   ```bash
   git status
   git diff --name-only --diff-filter=U
   git ls-files -u
   ```

   Identify merge, cherry-pick, or rebase from `git status`. Do not run `--continue`, `--skip`, `--abort`, reset, or force-push unless the user explicitly asks or approves the specific state-changing operation.

2. Inspect each conflict before choosing a side.

   ```bash
   git diff -- path/to/file
   git show :1:path/to/file  # merge base, if present
   git show :2:path/to/file  # ours / current HEAD
   git show :3:path/to/file  # theirs / incoming commit
   ```

   For delete/modify conflicts, use `git ls-files -u`: a missing stage 2 means HEAD deleted the file; a missing stage 3 means the incoming change deleted it. Check whether the code moved or was intentionally removed before keeping a deletion.

3. Resolve by intent, not by label.

   - Keep compatible changes from both sides when they address independent concerns.
   - Prefer the currently maintained interface when the other side targets removed or refactored code.
   - When an incoming commit is comment-only or removes a now-obsolete type suppression, verify whether the target import, file, or suppression still exists.
   - Treat `ours`/`theirs` carefully during rebase: `ours` is the rebased-on branch and `theirs` is the commit being replayed.
   - If choosing one side would discard behavior rather than an obsolete edit, stop and ask the user.

4. Edit only the resolved files. Use `apply_patch` for file edits. Remove all conflict markers and do not alter unrelated code.

5. Verify and stage.

   ```bash
   rg -n '^(<<<<<<<|=======|>>>>>>>)' --glob '!*.lock' .
   git diff --check
   git diff --name-only --diff-filter=U
   git add path/to/resolved-file
   # or: git rm path/to/deleted-file
   git status
   ```

   Confirm that no unmerged paths remain. Run focused tests or static checks when the resolved code changed behavior; state clearly if none were run.

6. Hand off the operation.

   If a rebase or cherry-pick is paused, report that conflicts are fixed and provide the exact next command. Only execute it with user authorization. Expect later commits to introduce further conflicts and repeat the workflow.

## Checking Whether a Stale PR Still Has Meaningful Work

Before rebasing a long-lived branch, or when a rebase yields an empty branch, compare its original tip with the current base:

```bash
git merge-base origin/main <original-tip>
git diff --stat origin/main...<original-tip>
git diff --name-status origin/main...<original-tip>
git cherry origin/main <original-tip>
git log --oneline --all -- path/to/affected-file
```

`git cherry` reporting `+` means commits are not patch-identical to the base; it does not prove their intent remains necessary. Check for successor commits, moved files, removed imports, and refactored interfaces. Distinguish these conclusions explicitly:

- already merged unchanged;
- superseded by later equivalent work or refactoring;
- still needed and accidentally discarded during resolution.
