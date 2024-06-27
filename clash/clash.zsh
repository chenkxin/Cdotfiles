#/bin/zsh

DOTFILES=$HOME/.local/.Cdotfiles

export PATH=$HOME/.local/bin:$PATH
. $DOTFILES/clash/alias.zsh

. $DOTFILES/clash/proxy.zsh
. $DOTFILES/clash/clash_func.zsh
