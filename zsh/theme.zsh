ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

DOTFILES=$HOME/.local/.Cdotfiles
zinit ice depth=1; zinit light romkatv/powerlevel10k
. $DOTFILES/.p10k.zsh

zinit light zsh-users/zsh-autosuggestions
zinit load zdharma-continuum/history-search-multi-word
zinit light zsh-users/zsh-syntax-highlighting
