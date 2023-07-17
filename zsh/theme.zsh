# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
	source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# p10k
DOTFILES=$HOME/.local/.Cdotfiles
zinit ice depth=1
zinit light romkatv/powerlevel10k
[[ ! -f $DOTFILES/zsh/.p10k.zsh ]] || . $DOTFILES/zsh/.p10k.zsh

# some plugins
zinit light zsh-users/zsh-autosuggestions
zinit load zdharma-continuum/history-search-multi-word
zinit light zsh-users/zsh-syntax-highlighting
zinit snippet OMZ::plugins/autojump
# zi light-mode wait lucid for \
    # OMZ::plugins/autojump/autojump.plugin.zsh
