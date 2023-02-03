#!/bin/sh
mkdir ~/.sops && cd ~/.sops && age-keygen -o key
if [ -e $HOME/.bashrc ]; then
  echo "export SOPS_AGE_KEY_FILE=$HOME/.sops/key" >> ~/.bashrc && source "$HOME"/.bashrc
elif [ -e $HOME/.zshrc ]; then
  echo "typeset -g SOPS_AGE_KEY_FILE=$HOME/.sops/key" >> ~/.zshrc && source "$HOME"/.zshrc
else
  echo "add SOPS_AGE_KEY_FILE=$HOME/.sops/key to your shell .rc file"
fi