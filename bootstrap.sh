cp_file_if_exists() {
	if [ -f "$1" -a -e $2 ]; then
		cp "$1" "$2"
	fi
}

DOTFILES=$HOME/.local/.Cdotfiles

# initialization for the dotfiles project
check_project() {
	if [ ! -d "$DOTFILES" ]; then
		git clone --recursive https://github.com/chenxygh/Cdotfiles $DOTFILES
	fi
}

setup_config() {
	# zshrc
	cp zsh/.zshrc $HOME
	cp_file_if_exists zsh/.zsh_profile ~
	
	# clash
	if [ ! -f $HOME/.local/bin/clash ]; then
		bash $DOTFILES/clash/install.sh
	fi

    # tmux
    ln -sT $DOTFILES/tmux/.tmux/.tmux.conf $HOME/.tmux.conf
    cp $DOTFILES/tmux/.tmux/.tmux.conf.local $HOME

    # vim
	if [ ! -d "$HOME/.vim" ]; then
		mkdir $HOME/.vim
	fi
    ln -sT $DOTFILES/vim/vim-init $HOME/.vim/vim-init
    cp $DOTFILES/vim/.vimrc $HOME

	# git
	cp git/.gitconfig ~

	# ssh
    if [ ! -d "$HOME/.ssh" ]; then
        mkdir $HOME/.ssh
    fi
	cp_file_if_exists ssh/config ~/.ssh
}

main() {
    check_project
    cd $DOTFILES
    setup_config
    cd -
    exec zsh
}

main
