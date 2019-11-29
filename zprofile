export PATH="/usr/local/sbin:$PATH"

# nodenv
export PATH="$HOME/.nodenv/bin:$PATH"
eval "$(nodenv init -)"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# rbenv
export PATH="~/.rbenv/shims:/usr/local/bin:$PATH"
eval "$(rbenv init -)"

export PATH="/usr/local/Cellar/git/2.5.0/bin:$PATH"

# goenv
export PATH="$HOME/.goenv/bin:$PATH"
export GOENV_DISABLE_GOPATH=1
eval "$(goenv init -)"

# golang
export GOPATH=$HOME/Documents/git/go
export PATH=$GOPATH/bin:$PATH
export GOOGLE_APPLICATION_CREDENTIALS=$GOPATH/src/github.com/terfno/go_test/GAC.json

# SYSKEN PROXY
proxy_set(){
    export http_proxy="http://172.20.20.104:8080"
    export https_proxy=$http_proxy
    export all_proxy=$http_proxy
    npm -g config set proxy "http://172.20.20.104:8080"
    npm -g config set https-proxy "https://172.20.20.104:8080"
    git config --global http.proxy 172.20.20.104:8080
    git config --global https.proxy 172.20.20.104:8080
    echo -e "set proxy for sysken"
}
proxy_unset(){
    export http_proxy=""
    export https_proxy=""
    export all_proxy=""
    npm -g config delete proxy
    npm -g config delete https-proxy
    git config --global --unset http.proxy
    git config --global --unset https.proxy
    echo -e "unset proxy for sysken"
}

# Google search from terminal
ggrks(){
    open "https://www.google.co.jp/search?q=${*// /+}"
}
