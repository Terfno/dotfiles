export EDITOR=vim
export TERMINAL=wezterm
export SHELL="/bin/zsh"
export PATH="$HOME/.local/bin:$PATH"

bindkey -e

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
fi

# starship.rs
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# insert OSC133 into prompt for hooks for wezterm integration
if [[ ${TERM_PROGRAM-} == "WezTerm" ]]; then
  PROMPT=$'%{\e]133;A\e\\\\%}'"$PROMPT"$'%{\e]133;B\e\\\\%}'
fi

yy() {
  local last_cmd=$(fc -ln -1 | sed 's/^[[:space:]]*//')
  echo "Re-execute: $last_cmd"

  # bash/zsh compatible confirmation
  if [[ -n "$ZSH_VERSION" ]]; then
    read -q "?Continue? (y/n) "
    local answer=$?
    echo
  else
    read -p "Continue? (y/n) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
    local answer=$?
  fi

  if [[ $answer -eq 0 ]]; then
    eval "$last_cmd" | pbcopy
    echo "✓ Output copied to clipboard"
  else
    echo "Cancelled"
  fi
}

# Google search from terminal
ggrks(){
  open "https://www.google.co.jp/search?q=${*// /+}"
}
