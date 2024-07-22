GIT_NAME="chenkxin"

cp_file_if_exists() {
    if [ -f "$1" -a -e $2 ]; then
        cp "$1" "$2"
    fi
}

LOCAL_DIR=$HOME/.local
[ ! -d $LOCAL_DIR ] && mkdir -p "$LOCAL_DIR"
DOTFILES=$LOCAL_DIR/.Cdotfiles

# initialization for the dotfiles project
check_project() {
    if [ ! -d "$DOTFILES" ]; then
        git clone --recursive https://github.com/${GIT_NAME}/Cdotfiles $DOTFILES
    fi
}

setup_config() {
    # zshrc
    cp zsh/.zshrc $HOME/
    cp_file_if_exists zsh/.zsh_profile $HOME/
    
    # clash
    if [ ! -f $HOME/.local/bin/clash ]; then
        bash $DOTFILES/clash/install.sh
    fi

    # tmux
    ln -s $DOTFILES/tmux/.tmux/.tmux.conf $HOME/.tmux.conf
    cp $DOTFILES/tmux/.tmux/.tmux.conf.local $HOME

    # vim
    if [ ! -d "$HOME/.vim" ]; then
        mkdir $HOME/.vim
    fi
    ln -s $DOTFILES/vim/vim-init $HOME/.vim/vim-init
    cp $DOTFILES/vim/.vimrc $HOME

    # git
    cp git/.gitconfig $HOME/
}

install_common_software () {
    bash scripts/install.sh
}

main() {
    check_project
    cd $DOTFILES
    install_common_software
    setup_config
    cd -
    exec zsh
}

main
