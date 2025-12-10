#!/bin/bash

OS_NAME=$(uname)

if [ ${OS_NAME} = "Linux" ];then
  sudo apt install zsh git tmux vim
elif [ ${OS_NAME} = "Darwin" ];then
  brew install git tmux
else
  echo "System type error, only for Linux or Macos."
fi
