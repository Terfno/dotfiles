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
	cat ./gitcommit-template >> ~/.commit-template &&\
	git config --global commit.template ~/.commit-template

# brews
chrome:
	brew install google-chrome

ime:
	brew isntall google-japanese-ime

vscode:
	brew isntall visual-studio-code

skim:
	brew isntall skim

slack:
	brew install slack

discord:
	brew install discord

zoom:
	brew install zoom

gpg:
	brew install gpg-suite

appcleaner:
	brew install appcleaner

# lang
re:
	exec ${SHELL} -l

anyenv:
	brew install anyenv &&\
	echo 'export PATH="${HOME}/.anyenv/bin:${PATH}"' >> ~/.zprofile &&\
	echo 'eval "$(anyenv init -)"' >> ~/.zprofile &&\
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
