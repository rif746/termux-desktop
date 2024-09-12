#!/bin/sh

echo "Installing PHP DevTools"
pkg install git wget curl nodejs mariadb composer php neovim

echo "Configuring NeoVim"
cd ~/.config
git clone https://github.com/rif746/nvim.git

echo "Configuring MariaDB"
mariadb-install-db

