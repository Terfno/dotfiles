# set up terfno mac
c.f. https://scrapbox.io/terfno/dotfiles

```sh
$ make init
```

## zsh
dotfiles で管理する対話シェル設定は `.zshrc` に置く。

各マシン固有の設定や、dotfiles に入れたくない設定は `~/.zshrc` に残しつつ、次の 1 行で dotfiles 側を読み込む。

```zsh
[[ -f path_to/dotfiles/.zshrc ]] && source path_to/dotfiles/.zshrc
```

この構成なら、`~/.zshrc` はローカル専用の入口として使え、WezTerm shell integration や `fzf` / `starship` のような共有したい設定は dotfiles 側で管理できる。

WezTerm の `LEADER+c` は shell integration に依存する。`.zshrc` では `OSC 133` と `OSC 7` を出して semantic zone とカレントディレクトリを WezTerm に通知しているので、この設定は対話シェルで読み込まれている必要がある。

## memo
starship.rs

```sh
curl -sS https://starship.rs/install.sh | sh
```

`.zshrc` は `fzf` と `starship` に依存中。

wezterm copy (leader+c) は shell integration に依存。
.zshrc に hook definitons として `OSC 133` を出すコードが入っている。

依存している font
- Cica
- Nerd Font

デフォルトで XDG Base Directory を使うソフトウェアの files は `./xdg_config_home/*` へ
XDG Base 風味かどうかはいったん https://wiki.archlinux.jp/index.php/XDG_Base_Directory を参照して考える。
