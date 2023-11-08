#!/bin/bash

echo -e "\nUpdating repositories..."
sudo apt update

echo -e "\nInstalling requirements"
sudo apt install -y wget ca-certificates curl gnupg git

echo -e "\nDo you want to setup SSH keys (y/n)?"
read response

if [ "$response" = "y" ]; then

    echo -e "\nEmail: "
    read email
    ssh-keygen -t ed25519 -C "$email"
    ssh-add "$HOME/.ssh/id_ed25519"
    echo -e "Key generated!\nPublic key:"
    cat .ssh/id_ed25519.pub
    echo -e "\n\n Press anything to continue"
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
else
    echo -e "\nDocker installation skipped."
fi

echo -e "\nDo you want to clone AmeKanji (y/n)?"
read response

if [ "$response" = "y" ]; then
    echo -e "\nCloning AmeKanji..."
    mkdir -p "$HOME/Rep/AmeKanji/"
    git clone git@github.com:lesserfish/GoAme.git "$HOME/Rep/AmeKanji/"
else
    echo -e "\nAmeKanji skipped."
fi

echo -e "\nDo you want to clone Home Website (y/n)?"
read response

if [ "$response" = "y" ]; then
    echo -e "\nCloning Home Website..."
    mkdir -p "$HOME/Rep/Home/"
    git clone --recurse-submodule git@github.com:lesserfish/home.git "$HOME/Rep/Home/"
else
    echo -e "\nHome Website skipped."
fi

echo -e "\nDo you want to install Nginx (y/n)?"
read response

if [ "$response" = "y" ]; then
    sudo apt install -y nginx
    sudo cp "$HOME/install/lesserfish" /etc/nginx/sites-available/lesserfish
    sudo chown root:root /etc/nginx/sites-available/lesserfish
    sudo chmod 644 /etc/nginx/sites-available/lesserfish
    sudo ln -s /etc/nginx/sites-available/lesserfish /etc/nginx/sites-enabled/lesserfish
else
    echo -e "\nNginx skipped."
fi

echo -e "\nDo you want to setup Firewall (y/n)?"
read response

if [ "$response" = "y" ]; then
    sudo apt install -y ufw
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    echo -e "\nDo you want to allow HTTP?"
    read response
    if [ "$response" = "y" ]; then
        sudo ufw allow http
    fi
    echo -e "\nDo you want to allow HTTPS?"
    read response
    if [ "$response" = "y" ]; then
        sudo ufw allow https
    fi
    echo -e "\nDo you want to allow SSH?"
    read response
    if [ "$response" = "y" ]; then
        sudo ufw allow ssh
    fi
else
    echo -e "\nFirewall skipped."
fi

echo -e "\nDo you want to install tmux?"
read response

if [ "$response" = "y" ]; then
    sudo apt install -y tmux
else
    echo -e "\nTmux skipped."
fi  

echo -e "\nDo you want to setup dotfiles?"
read response

if [ "$response" = "y" ]; then
    mkdir -p "$HOME/Rep/dotfiles/"
    git clone git@github.com:lesserfish/dotfiles.git "$HOME/Rep/dotfiles/"
    cp "$HOME/Rep/dotfiles/home/.vimrc" "$HOME/.vimrc"
    cp "$HOME/Rep/dotfiles/home/.tmux.conf" "$HOME/.tmux.conf"
    mkdir -p "$HOME/.config/"
    cp -r "$HOME/Rep/dotfiles/home/.config/fish/" "$HOME/.config/fish/"
    cp -r "$HOME/Rep/dotfiles/home/.config/nvim/" "$HOME/.config/nvim/"
    fish -c "nvm install 18.7.0"
    nvim -c ":PluginInstall" -c ":qa"
    cd "$HOME/.vim/bundle/coc.nvim" && npm install
else
    echo -e "\nDotfiles skipped."
fi

