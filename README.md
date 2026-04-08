# set up terfno mac

- `bin/` に mitamae 類の実行ファイルを作るためのスクリプトがある。
- `config/` に管理している各種設定ファイルがある。
- `recipes/` に mitamae のレシピがある。設定ファイルの配置はこっちが担当していて、`config/` の構造はあんまり関係ない。

## install

- bootstrap homebrew and mitamae: `make bootstrap`
- apply: `make install`
- apply with dry-run: `make dry-install`

## todo

```
# 色
autoload -Uz colors
colors
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
```

LS_COLORS 何も考えてない…

```
git push --force-with-lease origin main
```

## memo

### wezterm copy

wezterm copy (`leader+c`) は prompt の見た目ではなく、WezTerm shell integration が作る semantic zone に依存。
`config/zsh/.zshrc` に hook definitions として `OSC 133` を出すコードが入っている。

制約:

- `wezterm` shell integration が有効であること
- zsh 側が `OSC 133` を正しく出していること
- semantic zone 自体が壊れている場合は正しく復元できないことがある
- `Ctrl+L` のような画面クリア後の prompt redraw では semantic zone が崩れることがあり、その直後の `leader+c` は prompt 行を出力として誤って含むことがある

### fonts

依存している font

- Cica
- Nerd Font

### recipes

helper.rb, xdg について。
XDG Base 風味かどうかはいったん https://wiki.archlinux.jp/index.php/XDG_Base_Directory を参照して考える。

### gh-exts

gh extensions は terfno/gh-exts で管理している。
gh のセットアップと同時に `gh ext install terfno/gh-exts`→`gh exts install` で再現できる想定。

### to manage

この dotfiles を管理するために必要なツール類は `make up` で pre-commit まで設定される。
`make format` で pre-commit 関係なくフォーマット実行できる。
今は jsonnetfmt, prettier, stylua がある。
