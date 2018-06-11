#!/bin/bash


mv tmux.conf ~/.tmux.conf
mv vimrc ~/.vimrc

cd

git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_awesome_vimrc.sh
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

mv ~/dotfiles/simple.zsh-theme ~/.oh-my-zsh/themes

echo "chpwd() ls" >> ~/.zshrc

rm -r ~/dotfiles
