cp_file_if_exists() {
	if [ -f "$1" -a -e $2 ]; then
		cp "$1" "$2"
	fi
}

DOTFILES=$HOME/.local/.Cdotfiles

# initialization for the dotfiles project
check_project() {
	if [ ! -d "$DOTFILES" ]; then
		git clone https://github.com/chenxygh/Cdotfiles $DOTFILES
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
}

main() {
    cd $DOTFILES
    check_project
    setup_config
    cd -
    exec zsh
}
