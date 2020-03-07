# set up terfno mac
https://twitter.com/terfno_mai/status/1236257885069299712

```sh
# xcode
xcode-select --install

# brew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew tap caskroom/cask

## opera
brew cask install opera

## chrome
brew cask install google-chrome

## google japanese ime
brew cask install google-japanese-ime

# git
## .gitignore_global
touch ~/.gitignore_global && cat ./gitignore_global >> ~/.gitignore_global && git config --global core.excludesfile ~/.gitignore_global

## commit-template
touch ~/.gitcommit-template && cat ./commit-template >> ~/.gitcommit-template && git config --global commit.template ~/.gitcommit-template

# docker
open https://download.docker.com/mac/stable/Docker.dmg
```
