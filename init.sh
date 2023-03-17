# 交互式模式的初始化脚本
# 防止被加载两次
if [ -z "$_INIT_SH_LOADED" ]; then
    _INIT_SH_LOADED=1
else
    return
fi

# 如果是非交互式则退出，比如 bash test.sh 这种调用 bash 运行脚本时就不是交互式
# 只有直接敲 bash 进入的等待用户输入命令的那种模式才成为交互式，才往下初始化
case "$-" in
    *i*) ;;
    *) return
esac

# 将个人 ~/.local/bin 目录加入 PATH
if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# 判断文件是否存在， 若存在， 则 source 一下
source_if_exists() {
  file="$1"

  if [ -f "$file" ]; then
    source "$file"
  fi
}

DOTFILES=$HOME/.local/.Cdotfiles

# zsh
. $DOTFILES/zsh/theme.zsh
. $DOTFILES/zsh/alias.zsh
source_if_exists ~/.zsh_profile

# clash
. $DOTFILES/clash/clash.zsh
. $DOTFILES/clash/proxy.zsh

# git
. $DOTFILES/git/alias.zsh

# 整理 PATH，删除重复路径
if [ -n "$PATH" ]; then
    old_PATH=$PATH:; PATH=
    while [ -n "$old_PATH" ]; do
        x=${old_PATH%%:*}      
        case $PATH: in
           *:"$x":*) ;;         
           *) PATH=$PATH:$x;;  
        esac
        old_PATH=${old_PATH#*:}
    done
    PATH=${PATH#:}
    unset old_PATH x
fi

export PATH
