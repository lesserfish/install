#!/bin/bash

echo -e "\nUpdating repositories..."
sudo apt update

echo -e "\nInstalling requirements"
sudo apt install -y wget ca-certificates curl gnupg git make

echo -e "\nDo you want to setup SSH keys (y/n)?"
read response

if [ "$response" = "y" ]; then

    echo -e "\nEmail: "
    read email
    ssh-keygen -t ed25519 -C "$email"
    ssh-add "$HOME/.ssh/id_ed25519"
    echo -e "Key generated!\nPublic key:"
    cat .ssh/id_ed25519.pub
    echo -e "\n\nPress anything to continue"
    read null
else
    echo -e "\nSSH skipped."
fi

echo -e "\nDo you want to install Fish (y/n)?"
read response

if [ "$response" = "y" ]; then
    echo -e "\nInstalling Fish..."
    sudo apt install -y fish
    chsh -s $(which fish)
else
    echo -e "\nFish installation skipped."
fi


echo -e "\nDo you want to install Neovim (y/n)?"
read response

if [ "$response" = "y" ]; then
    echo -e "\nDownloading Neovim..."
    NVIM_URL="https://github.com/neovim/neovim/releases/download/v0.8.2/nvim-linux64.deb"
    wget -O /tmp/nvim-linux64.deb "$NVIM_URL"
    if [ $? -eq 0 ]; then
        echo -e "\nDownload completed successfully. Installing Neovim!"
        sudo apt install /tmp/nvim-linux64.deb
    else
        echo -e "\nDownload failed with an error. Exit status: $?"
    fi
else
    echo -e "\nNeovim installation skipped."
fi

echo -e "\nDo you want to install Docker (y/n)?"
read response

if [ "$response" = "y" ]; then
    echo -e "\nDownloading Docker..."
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    # Add the repository to Apt sources:
    echo \
        "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo groupadd docker
    sudo usermod -aG docker $USER
    sudo apt install -y docker-compose
else
    echo -e "\nDocker installation skipped."
fi

echo -e "\nDo you want to install Nginx (y/n)?"
read response

if [ "$response" = "y" ]; then
    sudo apt install -y nginx
    sudo rm /etc/nginx/sites-enabled/default
        sudo systemctl restart nginx
else
    echo -e "\nNginx skipped."
fi

echo -e "\nDo you want to clone AmeKanji (y/n)?"
read response

if [ "$response" = "y" ]; then
    echo -e "\nCloning AmeKanji..."
    mkdir -p "$HOME/Rep/AmeKanji/"
    git clone git@github.com:lesserfish/GoAme.git "$HOME/Rep/AmeKanji/"
    echo -e "\nAdding AmeKanji to NGINX..."
    sudo cp "$HOME/install/nginx/amekanji" /etc/nginx/sites-available/amekanji
    sudo chown root:root /etc/nginx/sites-available/amekanji
    sudo chmod 644 /etc/nginx/sites-available/amekanji
    sudo ln -s /etc/nginx/sites-available/amekanji /etc/nginx/sites-enabled/amekanji

else
    echo -e "\nAmeKanji skipped."
fi

echo -e "\nDo you want to clone Home Website (y/n)?"
read response

if [ "$response" = "y" ]; then
    echo -e "\nCloning Home Website..."
    mkdir -p "$HOME/Rep/Home/"
    git clone --recurse-submodule git@github.com:lesserfish/home.git "$HOME/Rep/Home/"
    sudo mv "$HOME/Rep/Home/URMSimulator/public/" "/var/www/URM"
    sudo mv "$HOME/Rep/Home/KMPA/build/v1.0/build/" "/var/www/KMPA/"
    echo -e "\nAdding home website to NGINX..."
    sudo cp "$HOME/install/nginx/home" /etc/nginx/sites-available/home
    sudo chown root:root /etc/nginx/sites-available/home
    sudo chmod 644 /etc/nginx/sites-available/home
    sudo ln -s /etc/nginx/sites-available/home /etc/nginx/sites-enabled/home

else
    echo -e "\nHome Website skipped."
fi

echo -e "\nDo you want to setup Owncloud? (y/n)"
read response

if [ "$response" = "y" ]; then
    cp -r "$HOME/install/owncloud" "$HOME/Rep/owncloud/"
    echo -e "\nAdding Owncloud to NGINX..."
    sudo cp "$HOME/install/nginx/owncloud" /etc/nginx/sites-available/owncloud
    sudo chown root:root /etc/nginx/sites-available/owncloud
    sudo chmod 644 /etc/nginx/sites-available/owncloud
    sudo ln -s /etc/nginx/sites-available/owncloud /etc/nginx/sites-enabled/owncloud
else
    echo -e "\nOwncloud skipped."
fi

echo -e "\nDo you want to setup Firewall (y/n)?"
read response

if [ "$response" = "y" ]; then
    sudo apt install -y ufw
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    echo -e "\nDo you want to allow HTTP (y/n)?"
    read response
    if [ "$response" = "y" ]; then
        sudo ufw allow http
    fi
    echo -e "\nDo you want to allow HTTPS (y/n)?"
    read response
    if [ "$response" = "y" ]; then
        sudo ufw allow https
    fi
    echo -e "\nDo you want to allow SSH (y/n)?"
    read response
    if [ "$response" = "y" ]; then
        sudo ufw allow ssh
    fi
else
    echo -e "\nFirewall skipped."
fi

echo -e "\nDo you want to install Tmux (y/n)?"
read response

if [ "$response" = "y" ]; then
    sudo apt install -y tmux
else
    echo -e "\nTmux skipped."
fi  

echo -e "\nDo you want to setup dotfiles (y/n)?"
read response

if [ "$response" = "y" ]; then
    sudo apt install -y silversearcher-ag
    mkdir -p "$HOME/Rep/dotfiles/"
    mkdir -p "$HOME/.config/"
    git clone git@github.com:lesserfish/dotfiles.git "$HOME/Rep/dotfiles/"
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    mv "$HOME/Rep/dotfiles/home/.vimrc" "$HOME/.vimrc"
    mv "$HOME/Rep/dotfiles/home/.tmux.conf" "$HOME/.tmux.conf"
    mv "$HOME/Rep/dotfiles/home/.config/nvim/" "$HOME/.config/nvim/"

    fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
    fish -c "fisher install jorgebucaran/nvm.fish"
    fish -c "nvm install 18.7.0"

    nvim -c ":PluginInstall" -c ":qa"
    fish -c "cd "$HOME/.vim/bundle/coc.nvim" && nvm use v18.7.0 && npm install"

    cp "$HOME/Rep/dotfiles/home/.config/fish/config.fish" "$HOME/.config/fish/config.fish"
    rm -rf "$HOME/Rep/dotfiles"
else
    echo -e "\nDotfiles skipped."
fi

# Flush stdin. There is some trash left behind from the installation process.
read -t 1 -n 10000 discard 

echo -e "\nDo you want to install Golang (y/n)?"
read response

if [ "$response" = "y" ]; then
    sudo apt install -y golang
else
    echo -e "\nGolang skipped."
fi

echo -e "\nDo you want to install Haskell? (y/n)"
read response

if [ "$response" = "y" ]; then
    echo -e "\nIs this Ubuntu 20.04 (a) or Ubuntu 22.04 (b)?"
    read response
    if [ "$response" = "a" ]; then
        sudo apt install -y build-essential curl libffi-dev libffi7 libgmp-dev libgmp10 libncurses-dev libncurses5 libtinfo5
    elif [ "$response" = "b" ];  then
        sudo apt install -y build-essential curl libffi-dev libffi8ubuntu1 libgmp-dev libgmp10 libncurses-dev libncurses5 libtinfo5
    else 
        sudo apt install -y build-essential curl libffi-dev libffi7 libgmp-dev libgmp10 libncurses-dev libncurses5 libtinfo5
    fi
    curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
    fish -c "fish_add_path $HOME/.cabal/bin"
    fish -c "fish_add_path $HOME/.ghcup/bin"
else
    echo -e "\nHaskell skipped."
fi

echo -e "\nDo you want to install Python? (y/n)"
read response

if [ "$response" = "y" ]; then
    sudo apt install -y python3
else
    echo -e "\nPython skipped."
fi


