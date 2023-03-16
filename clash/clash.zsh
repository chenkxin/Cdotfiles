#/bin/zsh

. ./proxy.zsh
. ./clash_func.zsh
export PATH=$HOME/.local/bin:$PATH
alias clash="nohup clash > /dev/null 2>&1 &"
