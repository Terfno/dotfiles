export EDITOR=vim
export TERMINAL=wezterm
export SHELL="/bin/zsh"
export PATH="$HOME/.local/bin:$PATH"

bindkey -e

# 補完
autoload -U compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:default' menu select=2
zstyle ':completion:*' verbose yes
zstyle ':completion:*' completer _expand _complete _match _prefix _approximate _list _history
zstyle ':completion:*:messages' format '%F{YELLOW}%d'$DEFAULT
zstyle ':completion:*:warnings' format '%F{RED}No matches for:''%F{YELLOW} %d'$DEFAULT
zstyle ':completion:*:descriptions' format '%F{YELLOW}completing %B%d%b'$DEFAULT
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:descriptions' format '%F{yellow}Completing %B%d%b%f'$DEFAULT
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# define hooks for wezterm integration
if [[ ${TERM_PROGRAM-} == "WezTerm" ]]; then
  autoload -Uz add-zsh-hook

  __wezterm_precmd() {
    printf '\e]133;D;%s\e\\' "$?"
    printf '\e]133;A\e\\'
    printf '\e]7;file://%s%s\e\\' "$HOST" "$PWD"
  }

  __wezterm_preexec() {
    printf '\e]133;C\e\\'
  }

  add-zsh-hook precmd __wezterm_precmd
  add-zsh-hook preexec __wezterm_preexec
fi

# fzf
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
else
  echo "fzf not found, skipping fzf integration"
fi

# starship.rs
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
else
  echo "starship not found, using default prompt"
fi

# insert OSC133 into prompt for hooks for wezterm integration
if [[ ${TERM_PROGRAM-} == "WezTerm" ]]; then
  PROMPT=$'%{\e]133;A\e\\\\%}'"$PROMPT"$'%{\e]133;B\e\\\\%}'
fi

# alias ls lsd
if command -v lsd >/dev/null 2>&1; then
  alias ls='lsd --color=auto'
else
  echo "lsd not found, using default ls"
  alias ls='ls --color=auto'
fi

# Google search from terminal
ggrks(){
  open "https://www.google.co.jp/search?q=${*// /+}"
}
