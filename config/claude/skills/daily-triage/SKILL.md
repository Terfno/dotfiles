---
name: daily-triage
description: Use when the user asks what they should do today, to survey Slack/Linear/GitHub/Notion/Calendar for pending work, or to plan today's schedule — e.g. 「今日やるべきことリスト作って」「巡回して」「朝のタスク整理して」「今日の予定組んで」
---

# Daily Triage

Slack・Linear・GitHub・Notion・Google Calendar を並列巡回して「今日やるべきことリスト」を作る。**巡回は読み取り専用**（投稿・リアクション・issue 更新・コメント・マージは一切しない）。唯一の書き込みはカレンダー予定登録で、必ずユーザーの OK を挟む（最終セクション参照）。

## 手順

1. 今日の日付・曜日を確認し、検索開始日（＝拾いたい最初の日）を親が決める。通常は 3 日前、月曜は前週金曜、連休明けなら休み初日
2. general-purpose agent を **5つ同時に（1メッセージで）** バックグラウンド起動する（Slack / Linear / GitHub / Notion / Calendar）。**Agent ツールの `model` パラメータに `sonnet` を指定する**（巡回は収集作業なので上位モデル不要）。プロンプトには **今日の日付・検索開始日・ユーザーのメールアドレス（コンテキストの userEmail）** を必ず埋め込む。Slack/Linear/Notion の ID は各エージェントがメール・名前から特定、GitHub は `gh api user --jq .login`
3. **全部の完了通知が揃うまで待つ**。揃う前に結果を推測・出力しない
4. 結果を突き合わせて統合し、リストを出力する
5. リスト出力に続けて、同じターンでカレンダーへの割り付け案を提示し、登録するか質問する（最終セクション参照）

## 各エージェントのプロンプト要点

共通で必ず含める: 「書き込み系操作は一切しない」「結果は人間向け文章ではなく構造化データ（フィールド付き箇条書き）で返す（親がそのまま統合に使う）」「解決済み・情報共有のみは除外」

### Slack エージェント
- まず ToolSearch で mcp__claude_ai_Slack__ 系ツール（slack_search_users, slack_search_public_and_private, slack_read_thread, slack_read_channel）のスキーマをロードさせる
- slack_search_users で自分のユーザー ID を特定 → 検索開始日以降のメンション・依頼・レビュー依頼を検索（例: `<@USERID> after:YYYY-MM-DD`、`to:@自分`）。`after:` は指定日を**含まない**ので、検索開始日の**前日**を指定するようプロンプトに明記する
- ヒットしたメッセージは slack_read_thread でスレッド全体を読み、既に返信・解決済みなら除外
- bot からの DM（勤怠エラー、Linear リマインダー、GitHub pending review 通知、オンコール/当番通知）も検索対象。人間からの未返信 DM も確認。検索で拾えない領域があれば無理に探さず「未確認」と明記して返させる
- 返させる: チャンネル/発言者/日時、要約 1-2 行、対応が必要な理由、緊急度（高/中/低）、パーマリンク

### Linear エージェント
- ToolSearch で `select:mcp__claude_ai_Linear__list_issues,mcp__claude_ai_Linear__list_users,mcp__claude_ai_Linear__get_issue,mcp__claude_ai_Linear__list_comments,mcp__claude_ai_Linear__get_project,mcp__claude_ai_Linear__list_cycles` をロードさせる
- list_users で自分を特定 → **自分アサインの未完了 issue を全部**取得し、各 issue の属性として優先度・現在サイクルに入っているか・期日を報告させる（絞り込み条件ではない）
- 各 issue の直近コメントを読み、ボールが自分にあるか他者の返信待ちかを判断させる
- 返させる: ID とタイトル併記（例: DLG-747 カスタムテンプレートの…）、状態/優先度/サイクル/期日、**所属プロジェクトとその target date**、直近の動き、今日やるべき理由、URL

### GitHub エージェント
- `gh` CLI を使う。`gh auth status` と `gh api user --jq .login` で自分を確認してから:
  - レビュー依頼: `gh search prs --review-requested=@me --state=open --json repository,title,number,url,updatedAt,author`
  - 自分の open PR: `gh search prs --author=@me --state=open --json repository,title,number,url,updatedAt,isDraft` → 各 PR を `gh pr view <url> --json reviewDecision,statusCheckRollup,mergeable,reviews,comments` で深掘り
  - assigned issue: `gh search issues --assignee=@me --state=open ...`（open 全件。古すぎるものは対応不要側に回す）
  - メンション: `gh search issues --mentions=@me --state=open --updated=">=検索開始日" ...`（全件だと膨大なので期間で絞る。PR も同様）
- 判定させる: CI 落ち、コンフリクト、approve 済みマージ待ち、レビューコメント未返信、draft のまま停滞
- 返させる: repo/番号/タイトル/URL、種別、状態、必要アクションと緊急度

### Notion エージェント
- ToolSearch で `select:mcp__claude_ai_Notion__notion-search,mcp__claude_ai_Notion__notion-fetch,mcp__claude_ai_Notion__notion-query-meeting-notes,mcp__claude_ai_Notion__notion-get-users,mcp__claude_ai_Notion__notion-get-comments` をロードさせる
- notion-get-users（`user_id: "self"`）で自分を特定
- notion-query-meeting-notes で検索開始日以降の自分が参加した会議ノートを取得（created_time の date range filter）→ 各ノートを fetch して**自分宛ての action item・宿題**を抽出
- notion-search で自分の名前をクエリに検索（更新日フィルタは存在しないのでフィルタなしで検索し、結果の最終更新日時が検索開始日以降のものだけに足切りする）→ レビュー依頼・記入依頼っぽいものを fetch して確認（get-comments で自分宛てメンションの有無も見る）
- 網羅は不可能なので深追いしない。会議の宿題とレビュー依頼の 2 観点に絞り、それ以外は拾えた分だけでよい
- 返させる: ページ名/URL、依頼元（会議名 or 人）、内容要約、対応理由、緊急度

### Calendar エージェント
- ToolSearch で `select:mcp__claude_ai_Google_Calendar__list_events,mcp__claude_ai_Google_Calendar__list_calendars` をロードさせる。**見つからない or authenticate 系しかなければ未認証**なので、「⚠️ Calendar 未認証（/mcp から認証が必要）」とだけ返して終了させる
- 認証済みなら: 今日の予定を全部取得（終日予定含む）
- 勤務時間帯はデフォルトで **10:00〜19:00、昼休み 12:00〜13:00** を仮定する（ユーザーから指定があればそれを優先し、プロンプトに埋め込む）。仮定した値は結果に明記させる
- 返させる: 各予定の件名/開始・終了時刻/参加必須か（自分が主催 or 出席承諾済みか）、勤務時間帯内の空き時間帯のリスト、会議と昼休みを除いた可処分時間の合計（h）、仮定した勤務時間帯

## 統合のしかた

- 同じ PR / issue が複数ソースに出たら 1 項目にまとめ、情報を合算する（例: Linear「In Review」+ GitHub「approve 済み・質問未返信」+ Slack「督促あり」→ 返信してマージ、という 1 アクションに）
- 各タスクに**見積もり時間**を付ける（15分/30分/1h/2h の粒度。タスク内容から親が推定し、確信がなければ「?」を付ける。2h を超えそうなものは合計値（例: 4h）で書き、カレンダー登録時に 2h ごとのブロックに分割する）
- カレンダーの可処分時間と見積もり合計を比べ、明らかに入り切らなければ「高」までで今日は打ち止めと提案する
- 依存関係を明示する（例: backend PR マージ → frontend PR を un-draft できる）
- 期限の根拠を拾う（Linear プロジェクトの target date、オンコール当番日、勤怠の締め）
- レビュアーの不在情報（休暇など）が Slack から拾えたら、待っても進まない項目の判断に使う

## 出力フォーマット

エージェントが返す緊急度は参考値。**最終的な優先度は親が統合後に再判定する**（複数ソースの督促・期限・依存関係を見てから決まるため）。

冒頭 1-2 文で今日の最重要ポイントを言い切り、続けて今日の会議予定と可処分時間を 1 行で示す（Calendar 未認証ならその旨）。その後:

1. **まずこれ** — 即片付く事務（勤怠修正など）
2. **高** — 今日必須（期限直前のマージ待ち、レビュー依頼など）
3. **中** — 今日〜明日中
4. **低** — 判断だけすればいいもの

各項目: リンク付きで対象を示し、見積もり時間、「なぜ今日か」と「具体的なアクション」を 1 行ずつ。末尾に「対応不要と判断して除外したもの」を 1-2 行で添える。最後におすすめの着手順を 1 行。

## カレンダーへの予定登録

リスト出力の直後に、ユーザーに頼まれなくても割り付け案を提示して「登録していいか」を質問する。登録するのはユーザーが OK したときだけ。断られたら（または返答が別の話題なら）何も書き込まない。

1. Calendar が未認証なら案は出さず、「予定登録したい場合は /mcp から claude.ai Google Calendar を認証してください」と一言添えるだけにする。認証してもらえたら、今日の予定と空き時間帯を取得してから次へ進む
2. 現在時刻を確認し、タスクを**今から先の**空き時間帯に割り付けた案を提示する: 対象は「まずこれ」と「高」全部＋可処分時間に収まる範囲で「中」（どこまで入れたか・何を明日送りにしたかを案に明記）。各ブロック＝タスク名＋見積もり時間（2h 超は 2h ごとに分割）、ブロック間に**インターバル 15 分**（ユーザー指定があればそれに従う）を挟む。既存の予定・昼休み（Calendar エージェントと同じ仮定）とは重ねない
3. 案の提示と同時に AskUserQuestion で「この案で登録するか / 修正するか」を質問する
4. OK をもらってから、ToolSearch で `select:mcp__claude_ai_Google_Calendar__create_event` をロードしてカレンダーに登録する（タイトルにタスク名、説明欄に対象 URL を入れる）。**OK 前に作成しない**

## 注意

- リスト作成後に「返信して」「マージして」等を頼まれたら、それは書き込み操作なので内容を確認してから実行する
- エージェントが 1 つ失敗したら、その領域だけ 1 回再実行する。それでも失敗（認証切れ等）なら「⚠️ ◯◯ は取得できなかった」とリスト冒頭に明記した上で、残りのソースで出力する
