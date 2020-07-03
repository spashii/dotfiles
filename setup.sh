#!/bin/bash

# debian/ubuntu based
# git, zsh, nvim, node, tmux

# paths
mkdir -p ~/.zsh
mkdir -p ~/.config
mkdir -p ~/.config/nvim
mkdir -p ~/.tmux

# curl
echo "(setup) checking for curl"
if ! command -v curl &> /dev/null
then
    echo "(setup) installing curl"
    sudo apt install curl
else
    echo "(setup) curl found"
fi

# git
echo "(setup) checking for git"
if ! command -v git &> /dev/null
then
    echo "(setup) installing git"
    sudo apt install git
else
	echo "(setup) git found"
fi

# zsh 
echo "(setup) installing zsh"
sudo apt install zsh
echo "(setup) configuring zsh"
if [ -e ~/.zshrc ]
then
    echo "(setup) ~/.zshrc already exists"
	read -p "(setup) replace ~/.zshrc (y/n)?" -n 1 -r
	echo
	if [[ ! $REPLY =~ ^[Yy]$ ]]
	then
        echo "(setup) exiting"
		[[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
	fi
	rm ~/.zshrc
fi
ln -svf "$(pwd)/.zshrc" ~/.zshrc
echo "(setup) installing pure"
git clone https://github.com/sindresorhus/pure.git ~/.zsh/pure
echo "(setup) installing zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
echo "(setup) installing zsh-syntax-highlighting"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
echo "(setup) installing tree"
sudo apt install tree
read -p "(setup) change shell to zsh (y/n)?" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	chsh -s /bin/zsh
	echo "(setup) shell changed to zsh"
fi
echo "(setup) configured zsh"

# nvim 
echo "(setup) installing neovim"
sudo apt install neovim
echo "(setup) configuring neovim"
if [ -e ~/.config/nvim/init.vim ]
then
    echo "(setup) ~/.config/nvim/init.vim already exists"
	read -p "(setup) replace ~/.config/nvim/init.vim (y/n)?" -n 1 -r
	echo
	if [[ ! $REPLY =~ ^[Yy]$ ]]
	then
        echo "(setup) exiting"
		[[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
	fi
	rm ~/.config/nvim/init.vim
fi
ln -svf "$(pwd)/init.vim" ~/.config/nvim/
echo "(setup) installing vim-plug"
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
# node
echo "(setup) installing n"
curl -L https://raw.githubusercontent.com/tj/n/master/bin/n -o ~/n
sudo bash ~/n lts
# clangd
echo "(setup) installing clangd"
sudo apt-get install clangd-9
sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-9 100
# nvim-plugs
echo "(setup) installing neovim plugins"
nvim +PlugInstall +qall
echo "(setup) configuring coc-nvim"
nvim -c 'CocInstall -sync coc-clangd coc-css coc-html coc-json coc-python coc-sh coc-tsserver|q'
echo "(setup) configured neovim"

# tmux
echo "(setup) installing tmux"
sudo apt install tmux
echo "(setup) configuring tmux"
if [ -e ~/.tmux.conf ]
then
    echo "(setup) ~/.tmux.conf already exists"
	read -p "(setup) replace ~/.tmux.conf (y/n)?" -n 1 -r
	echo
	if [[ ! $REPLY =~ ^[Yy]$ ]]
	then
        echo "(setup) exiting"
		[[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
	fi
	rm ~/.tmux.conf
fi
ln -svf "$(pwd)/.tmux.conf" ~/.tmux.conf
echo "(setup) configuring tpm"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
echo "(setup) configured tmux"

# echo "(setup) manually install nvim plugs"
# echo "(setup) do the following in nvim"
# echo "        :PlugInstall"
# echo "        :CocInstall -sync coc-clangd coc-css coc-html coc-json coc-python coc-sh coc-tsserver"
echo "(setup) do the following in tmux"
echo "        <C-A> + I"
echo "(setup) done"

