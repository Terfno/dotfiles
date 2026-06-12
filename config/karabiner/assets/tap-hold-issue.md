# Karabiner tap-hold 問題の試行錯誤メモ

## 構成

ファイル: `stapler-mini-extend-qwerty.json`

全 12 箇所の tap-hold（`to_if_alone` + `to`）がある。
- `caps_lock` → tap: `a`, hold: `left_control`
- `return_or_enter` → tap: `hyphen`, hold: `right_control`
- `left_shift` → tap: `z`, hold: `left_shift`
- `z` → tap: `x`, hold: `left_option`
- `x` → tap: `c`, hold: `left_command`
- `period` → tap: `m`, hold: `right_command`
- `slash` → tap: `comma`, hold: `right_option`
- `right_shift` → tap: `period`, hold: `right_shift`
- `left_command` → tap: `tab`, hold: `left_command`
- `spacebar` → tap: `spacebar`, hold: `set_variable layer1`
- `right_command` → tap: `return_or_enter`, hold: `set_variable layer2`
- `right_option` → tap: `delete_or_backspace`, hold: `right_command`

## 元の問題

`period`（物理キー）は tap で `m`、hold で `right_command` になる設定。
`mo` と入力しようとすると `right_command o` になる。

これは以下の理由:
- 物理的には `period`（=`m`）→ `[`（=`o`）というローリング打鍵になる
- `period` を押したまま `[` を押すと、`to` が発火して `right_command` が送られる
- 次に `[` から `o` が出力されるが、`right_command` で修飾されて `right_command + o` になる

## 試行錯誤
AI に任せて試行錯誤してみた。
ちょいちょい筋が悪い。

### 1. `to_if_alone_timeout_milliseconds: 200`

`"parameters": { "basic.to_if_alone_timeout_milliseconds": 200 }` を全箇所に追加。

**結果**: 変わらず。むしろ単独タップでも `right_command` down/up + `m` down/up の 4 キーが入力される状態が継続。
timeout を短くしても、`to` が先に発火するため、tap-hold の hold 側が機能しない。

### 2. `to_delayed_action` 方式

```
"to_delayed_action": {
    "to_if_invoked": [],
    "to_if_cancelled": [{ "key_code": "m" }],
    "to_if_delayed": [{ "key_code": "right_command" }]
}
```

**結果**: tap しか効かない（`to_if_delayed` が発火しない）。全 tap-hold で hold が機能しなくなった。それはそう。
to_delayed_action は「押した瞬間は何も送らない → timeout 経過後に hold を送る → 途中で離したら tap を送る」という挙動になる。tap と hold を両立させることはできない。

### 3. 調査で判明したこと

Karabiner の `to_if_alone` + `to` の挙動を公式ドキュメントで確認:

- **`to`** は **key-down 時に即座に発火** する
- **`to_if_alone`** は **key-up 時に発火** する（単独かつ timeout 以内に離した場合）

つまり **両方発火するのは仕様** であり、バグではない。
押した瞬間にまず `to`（modifier）が送られ、話したときに `to_if_alone`（文字）が送られる。

### 4. `lazy: true` を追加

`to` に `lazy: true` を付けると、当該キーが **他のキーと一緒に押されたときだけ** modifier として送られる。単独タップでは modifier は送られず、`to_if_alone` だけが発火する。

```
"to_if_alone": [{ "key_code": "m" }],
"to": [{ "key_code": "right_command", "lazy": true }],
"parameters": { "basic.to_if_alone_timeout_milliseconds": 300 }
```

**結果**: 大幅に改善。単独タップでは正しく文字だけが出力される。
timeout は 200ms で QMK default と同じにした。

## 残課題

`lazy` は「他キーが押された瞬間」に modifier を発火させる。そのため、`period` を押したまま `[` を押すローリング打鍵では、`[` が押された瞬間に `right_command` が発動する。これは timeout の調整では解決できない（timeout 以前に、他キーが押されたという条件が先に成立するため）。

根本解決には別の設計が必要:

- **`simultaneous` 方式**: 特定の2キーの同時押し（`period + w` = `right_command + w` のように）のみで修飾。`period` 単独や `period, [` の順次入力では修飾しない
- **専用レイヤーキー方式**: 特定キー（spacebar 等）を押しながら打つと修飾。今の layer1/layer2 の仕組みを modifier 用に拡張

現在は `lazy` + 300ms の状態で妥協している。ローリング問題は tap-hold の本質的な限界であり、完全回避には設計変更が必要。

## Letter key holding modifier パターン（次の試行）

公式の [Letter key holding modifier](https://karabiner-elements.pqrs.org/docs/json/expert-complex-modifications-examples/letter-key-holding-modifier/) を参考に、より踏み込んだ方式。

### `to_delayed_action` の正しい挙動

最初に試した時は中身を理解していなかった。正しくは:

- **`to_if_invoked`**: delay 以内に **他キーが押されなかった** 場合に発火
- **`to_if_canceled`**: delay 以内に **他キーが押された** 場合に発火

### 構造

```json
{
    "to_if_held_down": [{ "key_code": "right_command", "lazy": true }],
    "to_after_key_up": [{ "halt": true }],
    "to_if_alone": [{ "key_code": "m" }],
    "to_delayed_action": {
        "to_if_canceled": [{ "key_code": "m" }]
    },
    "parameters": {
        "basic.to_if_alone_timeout_milliseconds": 200,
        "basic.to_if_held_down_threshold_milliseconds": 200,
        "basic.to_delayed_action_delay_milliseconds": 200
    }
}

`to_if_held_down` にも `lazy: true` が必要。これにより「他キーが押されたときだけ modifier を送る」ようになり、単独ホールド時の無駄な down/up も防げる。

}
```

3つのパラメーターをすべて同じ値（300ms）に揃える。

### 動作

```
time →                300ms
threshold ─────────────┼──────────────────
                      ↑                 ↑
             tap 判定領域       hold 判定領域
           (to_if_alone)    (to_if_held_down)
```

### ケース A: 単独クイックタップ（200ms で離す）

```
period  ┌──────┘               出力: m
        │ 200ms │                    ↑
        │       │              to_if_alone 発火
```

`to_if_alone` が発火 → `m` ✅

### ケース B: 単独 300ms 以上ホールド（他キー押さず）

```
period  ┌──────────────────────┘
        │    300ms    │         出力: right_command が一瞬 down/up
        │             │              ↑
        │      right_command│  to_if_held_down 発火
```

`to_if_held_down` が `right_command` を送信 → period ↑ で up。他キーがなければ実害なし ✅

### ケース C: 長押し + 他キー（300ms 超えてから）

```
period  ┌──────────────────────┐
        │    300ms    │        │   出力: right_command + o
        │             │        │        ↑
        │      rcmd↓  │  [ ↓  │  right_command が修飾
[       ┌──────────────┘
```

1. 300ms 経過 → `to_if_held_down` → `right_command` down
2. `[` ↓ → `right_command` がアクティブ → `right_command + o`
3. `period` ↑ → `right_command` up ✅

### ケース D: ローリング（300ms 以内に `[` を押す）

**ここが `lazy` 方式との本質的な差。**

```
period  ┌─────┐
        │80ms │       ← 300ms 以内に離す
        │     │      出力: m o
[           ┌──┘          ↑   ↑
            │       to_if_canceled  [→o
            │       が発火 → m
```

1. `period` ↓
2. `[` ↓ at 80ms（300ms 未満）
   - `to_if_held_down`: まだ発火していない
   - `to_if_alone`: キャンセル（他キーが押された）
   - **`to_if_canceled`**: delay 以内に他キーが押された → `m` を発火
3. `period` ↑ → `to_after_key_up` → halt
4. `[` は通常通り処理 → `o`

**出力: `m` → `o` = "mo"**（順序は不定で `om` になる可能性あり）✅

### `lazy` 方式との比較

| シナリオ | `lazy` 方式（現在） | Letter key holding modifier |
|---|---|---|
| 単独タップ | `m` ✅ | `m` ✅ |
| 長押し + 他キー | `right_command + o` ✅ | `right_command + o` ✅ |
| **ローリング** | **`right_command + o`** + `m` ❌ | **`mo` / `om`** ✅ |
| hold 発動までの遅延 | 0ms（他キーが押された瞬間） | 300ms（threshold 経過後） |

ローリング時に誤った修飾キーが絶対に漏れないのが最大の利点。代償として、hold 発動までに 300ms の遅延が生じる。

### 5. `to_if_held_down` 方式（現在）

`to` の即時発火が問題なので、代わりに `to_if_held_down` を使う。

```json
{
    "to_if_held_down": [{ "key_code": "right_command" }],
    "to_if_alone": [{ "key_code": "m" }],
    "parameters": {
        "basic.to_if_alone_timeout_milliseconds": 200,
        "basic.to_if_held_down_threshold_milliseconds": 200
    }
}
```

**動作**:
- タップ（< 200ms）→ `to_if_alone` → `m` ✅
- ホールド（> 200ms）→ `to_if_held_down` → right_command ✅
- ローリング（< 200ms で次キー）→ 200ms 未満で離鍵 → `to_if_alone` のみ → 文字 ✅
- ローリング（> 200ms で次キー）→ `to_if_held_down` 発火済み → `to_if_alone` がキャンセルされ m が消える ❌

**問題点**: `to_if_held_down` が発火すると `to_if_alone` がキャンセルされる。
そのため、ローリング時に修飾キーは出にくくなる（改善）が、文字が消える（新たな問題）。

### 6. `to_delayed_action.to_if_invoked` 方式（失敗）

`to_if_held_down` の代わりに `to_delayed_action.to_if_invoked` で修飾キーを送る。

```json
{
    "to_if_alone": [{ "halt": true, "key_code": "m" }],
    "to_delayed_action": {
        "to_if_canceled": [{ "halt": true, "key_code": "m" }],
        "to_if_invoked": [{ "halt": true, "key_code": "right_command" }]
    }
}
```

**動作**:
- タップ → `to_if_alone` → 文字 ✅
- ローリング（delay 以内）→ `to_if_canceled` → 文字 ✅
- ホールド（delay 超）→ `to_if_invoked` → right_command が瞬時 down/up

**問題点**: `to_if_invoked` は修飾キーを持続できない（down/up で終了）。ホールド中に他キーを入力しても修飾されない ❌

### simultaneous ハイブリッド（次候補）

単一キーの tap-hold ではローリングと文字出力を両立できないため、
**問題のペアだけ simultaneous で補う** 方式。

```
tap-hold: 単一キーのみ → to_if_held_down + to_if_alone
simultaneous: 特定ペア → 直接文字出力（tap-hold より優先）
```

例: `period` + `o` → `m` + `o`
```json
{
    "from": {
        "simultaneous": [
            { "key_code": "period" },
            { "key_code": "o" }
        ],
        "simultaneous_options": { "key_down_order": "strict" },
        "modifiers": { "optional": ["any"] }
    },
    "to": [{ "key_code": "m" }, { "key_code": "o" }]
}
```

`simultaneous` は単一キーの basic manipulator より優先される。
150ms 以内のローリングは常に simultaneous が捕まえ、文字だけ出力される。
hold 閾値（200ms）に到達しないので、modifier が絶対に漏れない。

**必要な simultaneous ペア候補**（a, z, x, c, m, comma, period, hyphen の 8 キー）:
- period + 母音 (o/a/i/u/e) → m + 母音
- caps_lock + 子音 (k/s/t/n/h/m/r...) → 子音 + a
- など、日本語ローマ字で問題になる組み合わせを列挙する

---

## Rolling Pair Analysis (simultaneous 方式向け)

### 物理キー → 出力マッピング

extends.json + tap-hold を考慮した、出力文字→物理キーの対応。

| 出力文字 | 物理キー | 備考 |
|----------|----------|------|
| q | tab | extends |
| w | q | extends |
| e | w | extends |
| r | e | extends |
| t | r | extends |
| y | u | extends |
| u | i | extends |
| i | o | extends |
| o | p | extends |
| p | open_bracket | extends |
| a | caps_lock | **tap-hold** |
| s | a | extends |
| d | s | extends |
| f | d | extends |
| g | f | extends |
| h | j | extends |
| j | k | extends |
| k | l | extends |
| l | semicolon | extends |
| ; | quote | extends |
| z | left_shift | **tap-hold** |
| x | z | **tap-hold** |
| c | x | **tap-hold** |
| v | c | extends |
| b | v | extends |
| n | m | extends |
| m | comma | extends (→m) |
| , | slash | **tap-hold** (slash tap: comma) |
| . | right_shift | **tap-hold** (rshift tap: period) |
| / | right_shift | extends (→/) だが tap-hold で上書き |
| - | return_or_enter | **tap-hold** (return tap: hyphen) |

### 分析の見方

- **物理ペア**: `(tap-hold物理キー, 次物理キー)` — Karabiner simultaneous の `key_code` にそのまま使える
- **出力**: `(tap出力, 次出力)` — ユーザーが打ちたい文字列
- **物理距離**: 1=隣接, 2=1つ間, 3=遠い (ローリングしやすさ)
- **優先度**: HIGH=全コンテキストで頻出 / MEDIUM=一部で頻出 / LOW=稀

### 1. caps_lock → a / left_control

物理位置: ホーム行左端。隣接キーとのローリング頻発。

| 次物理キー | 次出力 | JP romaji | EN | PROG | 物理距離 | 優先度 |
|-----------|--------|-----------|----|------|---------|--------|
| m | n | な(a→な) | and, an, any | and | 3 | **HIGH** |
| a | s | さ(a→さ) | as, ask, aspect | as, assert, async | 1 | **HIGH** |
| e | r | ら(a→ら) | are, around, art | array, arg, arrow | 3 | **HIGH** |
| r | t | た(a→た) | at, attach, attack | at, attr | 3 | **HIGH** |
| j | h | は(a→は) | — | — | 3 | MEDIUM |
| , | m | ま(a→ま) | am, among, amount | — | 4 | MEDIUM |
| l | k | か(a→か) | — | — | 3 | MEDIUM (JP heavy) |
| o | i | い(a→い→愛) | air, aim | async | 4 | MEDIUM |
| f | g | が(a→が) | ago, again, against | — | 3 | MEDIUM |
| s | d | だ(a→だ) | add, address, advance | — | 2 | MEDIUM |
| v | b | ば(a→ば) | able, about, above | abstract | 3 | MEDIUM |
| i | u | う(a→う→合う) | author, audience | — | 4 | MEDIUM (JP) |
| u | y | や(a→や→あや) | — | — | 4 | LOW |
| q | w | わ(a→わ) | await, away, aware | await | 4 | LOW |
| [ | p | ぱ(a→ぱ) | ap/apply | — | 4 | LOW |
| d | f | — | after, afternoon | — | 3 | LOW |
| ; | l | — | all, also, already | — | 4 | MEDIUM |
| p | o | お(a→お→青) | — | — | 4 | LOW (JP only) |
| w | e | え(a→え→敢え) | — | — | 3 | LOW |
| x | c | — | act, actual, account | — | 3 | MEDIUM |

### 2. return_or_enter → hyphen / right_control

物理位置: メインキー群の右端。アルファベットの隣接キーなし。

| 次物理キー | 次出力 | Context | 優先度 |
|-----------|--------|---------|--------|
| spacebar | space | 複合語後, -> 後 | LOW |
| — | — | ー(長音)は末尾に来るため次キーなし | — |

**判定**: ほぼ問題にならない。hyphen は単独で使うか句読点の一部。`Cmd+Space` は Spotlight なので問題になるが、hyphen→space のローリングは稀。

### 3. left_shift → z / left_shift

物理位置: 最下段左端 (caps_lock の真下)。

| 次物理キー | 次出力 | JP romaji | EN | PROG | 優先度 |
|-----------|--------|-----------|----|------|--------|
| a | s | ざ→さ?? no — ざ→a(caps→a)=za | — | — | LOW |
| o | i | zi(じ) | zip, zig | — | LOW |
| p | o | zo(ぞ) | zone, zoo | — | LOW |
| i | u | zu(ず) | — | — | LOW |
| w | e | ze(ぜ) | zero | — | LOW |
| m | n | — | — | — | LOW |
| u | y | — | — | — | LOW |

**判定**: z は全コンテキストで頻度が低い。優先度 LOW。

### 4. z → x / left_option

物理位置: 最下段左から2番目 (left_shift の右隣)。

| 次物理キー | 次出力 | JP romaji | EN | PROG | 優先度 |
|-----------|--------|-----------|----|------|--------|
| r | t | xtu(っ) | — | — | MEDIUM (JP,っは高頻度) |
| a | s | — | — | x | LOW |
| p | o | — | — | xo | LOW |
| o | i | xi(ぃ) | — | — | LOW |
| w | e | xe(ぇ) | — | — | LOW |
| i | u | xu(ぅ) | — | — | LOW |
| caps_lock | a | xa(ぁ) | — | — | LOW |

**判定**: xtu(促音)は日本語で高頻度だが、「っ」の入力自体は `xtu` より `ltu` や子音重ね打法でも可能。ただし `xtu` は主要方式の一つ。`x` と `r` は物理的に離れているためローリングしにくい。優先度 LOW-MEDIUM。

### 5. x → c / left_command

物理位置: 最下段左から3番目 (z の右隣)。`c` は英語/プログラミングで高頻度。

| 次物理キー | 次出力 | JP romaji | EN | PROG | 物理距離 | 優先度 |
|-----------|--------|-----------|----|------|---------|--------|
| p | o | co(こ→アル) | code, come | const, config, collect | 3 | **HIGH** |
| j | h | chi(ち) / cha(ちゃ) | change, check, child | char, check, channel | 2 | **HIGH** |
| w | e | ce(★非標準) | center, certain | cell, center, cfg | 2 | **HIGH** |
| r | t | — | act, fact, perfect | struct, collect, context | 3 | **HIGH** |
| o | i | ci(★非標準) | city, civil | circle, cidr, ci | 3 | MEDIUM |
| a | s | — | case, cause | class, case, css | 1 | **HIGH** |
| d | f | — | — | cfg, cflags | 2 | MEDIUM |
| e | r | — | create, cream, crazy | crate, create | 2 | **HIGH** |
| i | u | cu(★非標準/つ) | culture, cup | custom, current | 3 | MEDIUM |
| l | k | — | — | ck(/rock) | 3 | MEDIUM |
| ; | l | — | close, clear, claim | clone, close, clean | 3 | MEDIUM |
| u | y | — | cycle, cyber | cycle, cy, cyan | 3 | LOW |
| m | n | — | — | cn, cname | 3 | LOW |
| , | m | — | — | cmake, cmd | 4 | LOW |
| left_shift | z | — | — | cz | 1 | LOW |
| c | v | — | — | cv | 1 | LOW |

(★非標準 = c で か行を表す方式。"ca/ci/cu/ce/co" で かきくけこ)

### 6. period → m / right_command

物理位置: 最下段右から3番目。右手中指・薬指。`m` は日本語で最高頻度 (ま行)。

| 次物理キー | 次出力 | JP romaji | EN | PROG | 物理距離 | 優先度 |
|-----------|--------|-----------|----|------|---------|--------|
| p | o | も(mo) | more, most, move | mod, module, move | 1 | **HIGH** |
| w | e | め(me) | me, message, method | mem, merge, meta | 4 | **HIGH** |
| o | i | み(mi) | mid, miss, mix | min, mix, mirror | 1 | **HIGH** |
| i | u | む(mu) | much, multi, must | mut, multi, mutex | 2 | **HIGH** |
| a | s | ま→さ？ ms | ms, miss | — | 3 | MEDIUM |
| r | t | も→た？ mt | — | mount, mount | 3 | MEDIUM |
| m | n | ん(m→n→な) | mn, mnemonic | — | 1 | MEDIUM |
| , | m | — | mm | — | 1 | MEDIUM |
| u | y | みゃ/みゅ/みょ(my) | my, system, many | my, symbol, sys | 2 | MEDIUM |
| e | r | ま→ら？ mr | — | mr | 2 | LOW |
| s | d | — | md | md (markdown) | 3 | LOW |
| f | g | — | mg (milligram) | — | 4 | LOW |
| d | f | — | mf | — | 3 | LOW |
| j | h | — | mh | — | 2 | LOW |
| l | k | — | mk | mk (make) | 1 | MEDIUM |
| ; | l | — | ml | ml (machine learning) | 2 | LOW |
| [ | p | — | mp (mp3) | mp, map | 2 | MEDIUM |
| /(slash) | ,(comma) | — | m, | — | 1 | LOW |
| c | v | — | mv (move) | mv | 4 | LOW |
| v | b | — | mb | mb (megabyte) | 4 | LOW |
| x | c | — | mc | mc (minecraft) | 4 | LOW |

### 7. slash → comma / right_option

物理位置: 最下段右から2番目 (period の右隣, right_shift の左隣)。

| 次物理キー | 次出力 | Context | 優先度 |
|-----------|--------|---------|--------|
| spacebar | space | 読点+空白（日本語, English） | HIGH? |
| tab | q | 読点改行後 | LOW |
| right_shift | .(period) | — | LOW |
| p | o | — | LOW |

ただし comma → space のローリングでは `right_option + space` が発生。Cmd+Space は Spotlight、Opt+Space は non-breaking space で実害少。優先度 LOW。

### 8. right_shift → period / right_hold

物理位置: 最下段右端。

| 次物理キー | 次出力 | JP romaji | EN | PROG | 優先度 |
|-----------|--------|-----------|----|------|--------|
| spacebar | space | 。+空白 | period+space | — | LOW |
| p | o | — | — | .o (object file) | LOW |
| a | s | — | — | .s (assembly) | LOW |
| m | n | — | — | .n, .net | MEDIUM |
| , | m | — | — | .method(), .map() | **HIGH** |
| j | h | — | — | .h (header file) | LOW |
| x | c | — | — | .c (source file) | LOW |
| /(slash) | ,(comma) | — | — | . | LOW |
| w | e | — | — | .exec(), .exe | LOW |
| e | r | — | — | .r, .rb | LOW |
| tab | q | — | — | .query() | LOW |

**判定**: プログラミングで `.method()` `.map()` `.then()` などが頻出。`.` の直後にメソッド名が来ることが多く、`right_shift + 次の英字` で modifier が漏れると Cmd+. のようなショートカットになる可能性。特に `.m` (right_shift + , → period 直後に m) は高頻度。

### 総合優先度ランキング (上位 20)

全コンテキストを横断した最重要ペア。simultaneous を実装する優先順位。

| 順位 | 物理ペア | 出力 | 根拠 | 優先度 |
|------|---------|------|------|--------|
| 1 | period + p | mo | **全**: JP(も) EN(more) PROG(mod) + **物理隣接** | ★★★ |
| 2 | period + o | mi | **全**: JP(み) EN(mid) PROG(min) + **物理隣接** | ★★★ |
| 3 | period + i | mu | **全**: JP(む) EN(much) PROG(mut) | ★★★ |
| 4 | x + p | co | **EN/PROG 最頻**: const, config, code | ★★★ |
| 5 | x + j | ch | **全**: JP(ち) EN(change) PROG(char) | ★★★ |
| 6 | caps_lock + m | an | **EN/PROG 最頻**: and, any, answer | ★★★ |
| 7 | caps_lock + a | as | **EN/PROG**: as, assert, async | ★★★ |
| 8 | caps_lock + e | ar | **EN/PROG**: are, array, arg | ★★★ |
| 9 | caps_lock + r | at | **EN/PROG**: at, attach, attr | ★★★ |
| 10 | period + w | me | **全**: JP(め) EN(me) PROG(mem) | ★★★ |
| 11 | x + w | ce | **EN/PROG**: cell, center, cfg | ★★☆ |
| 12 | x + e | cr | **EN/PROG**: create, crate, cross | ★★☆ |
| 13 | x + r | ct | **EN/PROG**: act, collect, context | ★★☆ |
| 14 | x + a | cs | **PROG**: class, case, css | ★★☆ |
| 15 | caps_lock + o | ai | **JP**: 愛/合う **EN**: air/aim | ★★☆ |
| 16 | caps_lock + j | ah | JP(あ→は), EN: ah | ★★☆ |
| 17 | caps_lock + , | am | EN: am, among JP: あま | ★★☆ |
| 18 | caps_lock + i | au | JP: 合う/会う EN: author | ★★☆ |
| 19 | right_shift + , | .m | **PROG**: .method(), .map() | ★★☆ |
| 20 | period + u | my | EN: my, many JP: みゃ/みゅ | ★★☆ |
| 21 | caps_lock + l | ak | **EN/PROG**: make, take, cake, break | ★★☆ |
| 22 | caps_lock + s | ad | EN: add, address PROG: add, admin | ★★☆ |
| 23 | caps_lock + f | ag | EN: again, against, ago | ★★☆ |
| 24 | caps_lock + v | ab | EN: about, above, able PROG: abstract | ★★☆ |
| 25 | caps_lock + ; | al | EN/PROG: all, align, alloc, alt | ★★☆ |
| 26 | x + o | ci | JP(ci→き) PROG: ci/cidr EN: city | ★★☆ |
| 27 | x + i | cu | JP(cu→く) **PROG**: custom, current | ★★☆ |
| 28 | x + d | cf | **PROG**: cfg, cflags | ★★☆ |
| 29 | period + [ | mp | **PROG**: map, mp EN: mp3 | ★★☆ |
| 30 | period + m | mn | EN: mn, mnemonic JP: m→n(ん→な) | ★★☆ |
| 31 | period + l | mk | **EN/PROG**: make, mkdir | ★★☆ |
| 32 | period + , | mm | EN: mm(単位), mm(うーん) | ★★☆ |
| 33 | right_shift + m | .n | **PROG**: .net, .next, .name() | ★★☆ |
| 34 | right_shift + j | .h | **PROG**: .h(header), .hpp | ★★☆ |
| 35 | right_shift + x | .c | **PROG**: .c(source), .class | ★★☆ |
| 36 | right_shift + p | .o | **PROG**: .o(object), .on() | ★★☆ |
| 37 | right_shift + a | .s | **PROG**: .s(assembly), .sql | ★★☆ |
| 38 | right_shift + w | .e | **PROG**: .exe, .exec(), .each() | ★★☆ |
| 39 | right_shift + e | .r | **PROG**: .rb(ruby), .rs(rust) | ★★☆ |
| 40 | right_shift + tab | .q | **PROG**: .query(), .qml | ★★☆ |
| 41 | z + r | xt | **JP**: xtu(っ) — 高頻度, ただし物理距離遠 | ★★☆ |
| 42 | z + caps_lock | xa | **JP**: xa(ぁ) | ★☆☆ |
| 43 | z + o | xi | **JP**: xi(ぃ) EN: xi(ギリシャ文字) | ★☆☆ |
| 44 | z + i | xu | **JP**: xu(ぅ) | ★☆☆ |
| 45 | left_shift + o | zi | **JP**: zi(じ) | ★☆☆ |
| 46 | left_shift + p | zo | **JP**: zo(ぞ) | ★☆☆ |
| 47 | left_shift + w | ze | **JP**: ze(ぜ) EN: zero, zebra | ★☆☆ |
| 48 | slash + spacebar | ,␣ | JP(、+空白) | ★☆☆ |
| 49 | return_or_enter + spacebar | -␣ | JP(ー+空白) | ★☆☆ |
| 50 | caps_lock + q | aw | EN: await, away PROG: await | ★☆☆ |

### 実装メモ

- `simultaneous` の `key_down_order`: `"strict"` を推奨 (tap-hold 側が必ず先行)
- `simultaneous_options.detect_key_down_uninterruptedly`: `true` を推奨 (間に他のキーが挟まっても検出)
- 同時押し判定時間: デフォルト 50ms。必要なら `"simultaneous_threshold_milliseconds"` で調整。JP romaji の高速連打(100-150ms)を拾いたい場合は 150ms 推奨。
- 対象外のキー (backspace, enter, tab, space など) は `simultaneous_options.key_up_when.simultaneous` で対処
- C と H は x + j (ch) でカバーするが、拡張ローマ字の "shi", "tsu", "fu" などは含まれない — これらは `si`, `tu`, `hu` で入力可能なので問題なし
- x + p (co) と x + a (cs) は物理的に隣接。ローリング頻発しやすい。

## 参考リンク

- [to.lazy (公式ドキュメント)](https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/to/lazy/)
- [to_if_alone (公式ドキュメント)](https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/to-if-alone/)
- [simultaneous (公式ドキュメント)](https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/from/simultaneous/)
- [Home Row Mods with KE（gregorias の記事）](https://gregorias.github.io/posts/home-row-mods-karabiner-elements/)
- [Letter key holding modifier（公式）](https://karabiner-elements.pqrs.org/docs/json/expert-complex-modifications-examples/letter-key-holding-modifier/)
