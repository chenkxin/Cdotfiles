#/bin/zsh

DOTFILES=$HOME/.local/.Cdotfiles
. $DOTFILES/clash/proxy.zsh
. $DOTFILES/clash/clash_func.zsh
export PATH=$HOME/.local/bin:$PATH
alias clash="nohup clash > /dev/null 2>&1 &"
