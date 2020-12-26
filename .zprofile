export PATH="/usr/local/sbin:$PATH"

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
