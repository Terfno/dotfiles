include_recipe 'helper'

# XDG_CONFIG_HOME style config
xdg 'git'
xdg 'gh'
xdg 'wezterm'

## partially managed config
xdg 'opencode/opencode.json' => 'opencode/opencode.json'
xdg 'opencode/tui.json' => 'opencode/tui.json'

## XDG_CONFIG_HOME ish config
xdg 'starship.toml' => 'starship/starship.toml'

# ~/.file style config
dotfile '.zshrc' => 'zsh/.zshrc'

# packages
package 'git'
package 'gh'
package 'opencode'
package 'starship'
brew_cask 'wezterm'
