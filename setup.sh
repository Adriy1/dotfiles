#!/bin/bash

if [ $(dpkg-query -W -f='${Status}' vim 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  sudo apt-get install vim;
fi

if [ $(dpkg-query -W -f='${Status}' tmux 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  sudo apt-get install tmux;
fi

if [ $(dpkg-query -W -f='${Status}' zsh 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  sudo apt-get install zsh;
fi

mv tmux.conf ~/.tmux.conf
mv vimrc ~/.vimrc

cd

git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_awesome_vimrc.sh
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)" & wait

mv ~/dotfiles/simple.zsh-theme ~/.oh-my-zsh/themes

echo "chpwd() ls" >> ~/.zshrc

rm -rf ~/dotfiles
