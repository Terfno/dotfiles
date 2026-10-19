---
name: fetching-gemini-meeting-notes
description: Use when the user wants to find, summarize, or catch up on a Google Meet meeting via its Gemini-generated notes — e.g. 「あの会議のメモ見せて」「先週の定例で何話した」「出れなかった会議の内容を教えて」、または daily-triage 等から会議のキャッチアップとして呼ばれる場合
---

# Fetching Gemini Meeting Notes

## 概要

Google Meet で「Gemini でメモを取る」が有効な会議は、終了後に Google Calendar のイベントへ添付ファイルとして議事メモ（Google ドキュメント）と録画が自動で付く。この skill はそれを見つけて中身を取得する手順。

## 手順

1. `mcp__claude_ai_Google_Calendar__search_events`（キーワード）または `list_events`（日付/期間指定）で対象の会議インスタンスを特定する。定例会議は毎回別インスタンスなので、必ず対象の日付を先に確定させる
2. イベントの `attachments` を確認する。`title` が「Gemini によるメモ」のものが議事メモの Google ドキュメント。録画は別の添付として付くことがある
3. メモの `fileUrl` から Drive ファイルを特定し、`mcp__claude_ai_Google_Drive__read_file_content`（または `download_file_content`）で本文を取得する
4. 取得した内容をもとに要約・引用して回答する

## Quick Reference

| したいこと | 使うツール |
|---|---|
| キーワードで会議を探す | `mcp__claude_ai_Google_Calendar__search_events` |
| 日付・期間で会議を探す | `mcp__claude_ai_Google_Calendar__list_events` |
| メモ本文を読む | `mcp__claude_ai_Google_Drive__read_file_content` |

## 見つからない場合

- 会議終了直後はまだ生成中の可能性がある（少し時間を置いて再確認するよう伝える）
- その会議で Gemini のメモ機能自体がオフだった可能性がある
- `description` 欄に Notion の議事録リンクが貼られているだけのケースもある。それは別の議事録なので、Gemini メモが欲しい場合は attachments を優先して見る

## よくある失敗

- 定例会議名だけで検索し、どのインスタンス（日付）かを特定せずに進めてしまう → 対象日を先に確定する
- `attachments` を見ずに `description` の Notion リンクを議事メモだと思い込む → `attachments` を優先して確認する
