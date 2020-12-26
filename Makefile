init:
	make xcode &&\
	make brew &&\
	make zshrc & make zprofile & make gitignore & make gitcommit &&\
	make chrome & make ime & make vscode & make skim & make slack & make discord & make zoom & make gpg & make appcleaner

xcode:
	xcode-select --install

brew:
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# zsh
zshrc:
	touch ~/.zshrc &&\
	cat ./.zshrc >> ~/.zshrc &&\
	source ~/.zshrc

zprofile:
	touch ~/.zprofile &&\
	cat ./.zprofile >> ~/.zprofile &&\
	source ~/.zprofile

# git config
gitignore:
	touch ~/.gitignore-global &&\
	cat ./gitignore-global >> ~/.gitignore-global &&\
	git config --global core.excludesfile ~/.gitignore-global

gitcommit:
	touch ~/.commit-template &&\
	cat ./commit-template >> ~/.commit-template &&\
	git config --global commit.template ~/.commit-template

# brews
chrome:
	brew install --cask google-chrome

ime:
	brew isntall --cask google-japanese-ime

vscode:
	brew isntall --cask visual-studio-code

skim:
	brew isntall --cask skim

slack:
	brew install --cask slack

discord:
	brew install --cask discord

zoom:
	brew install --cask zoomus

gpg:
	brew install --cask gpg-suite

appcleaner:
	brew install --cask appcleaner

# lang
re:
	exec $SHELL -l

anyenv:
	brew install anyenv &&\
	echo 'export PATH="$HOME/.anyenv/bin:$PATH"' >> ~/.zprofile &&\
	anyenv init &&\
	anyenv install --init

goenv:
	anyenv install goenv

pyenv:
	anyenv install pyenv

rbenv:
	anyenv install rbenv

nodenv:
	anyenv install nodenv
