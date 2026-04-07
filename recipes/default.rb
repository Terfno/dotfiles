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
package 'fzf'
package 'lsd'
package 'starship'
package 'opencode'

## cask apps
brew_cask 'wezterm'

# brew_cask 'visual-studio-code'
# brew_cask 'karabiner-elements'

# ### browsers
# brew_cask 'arc'
# brew_cask 'google-chrome'
# brew_cask 'firefox'

# ### others
# brew_cask 'appcleaner'
# brew_cask 'discord'
# brew_cask 'spotify'
# # brew_cask 'slack'
# # brew_cask 'zoom'

# opencode json build
execute 'render opencode.json' do
  command '../../config/opencode/render-config.sh'
end

# gh exts rebuild
execute 'gh-exts rebuild' do
  command 'gh ext install terfno/gh-exts'
  command 'gh exts install -y'
  user node[:user]

  extslist = run_command('gh exts list')
  puts " INFO : [gh-exts] installed extensions: #{extslist.stdout.strip}"
end
