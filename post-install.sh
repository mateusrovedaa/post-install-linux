#!/bin/bash

if [ "$1" == ""  || "$2" == "" ] ; then
    echo "${GREEN}Post install script to Ubuntu system based${RESET}"
    echo "Use mode: $0 gitusername gitemail"
else
    # Define git user and email
    GIT_USERNAME=$1
    GIT_EMAIL=$2
fi

GREEN=`tput setaf 2`
RESET=`tput sgr0`

echo "#####################"
echo "${GREEN}Post install script to Ubuntu system based${RESET}"
echo "#####################"

echo "${GREEN}-> Update apt repository${RESET}"
sudo apt update

echo "${GREEN}-> Upgrade apt packages${RESET}"
sudo apt upgrade -y

echo "${GREEN}-> Install basic packages${RESET}"
sudo apt install -y \
software-properties-common \
apt-transport-https \
ca-certificates \
curl \
gnupg \
lsb-release \
wget \
java-11-openjdk \ 
steam \
gimp \
kdenlive \
ansible \
git \
neofetch \
obs-studio \
gnome-tweaks \
virtualbox \
virtualbox-ext-pack \
chromium-browser \
hugo \
nextcloud-client \
nextcloud-client-nautilus

echo "${GREEN}-> Install VSCode${RESET}"
wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add –
sudo add-apt-repository “deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main”
sudo apt install code

echo "${GREEN}-> Configure Visual Studio Code${RESET}"
# TODO

echo "${GREEN}-> Configure git globally${RESET}"
git config --global user.email "$GIT_EMAIL"
git config --global user.name "$GIT_USERNAME"
git config --global init.defaultBranch main

echo "${GREEN}-> Configure bash git prompt${RESET}"
git clone https://github.com/magicmonty/bash-git-prompt.git ~/.bash-git-prompt --depth=1
echo "
# git-bash-prompt
if [ -f "$HOME/.bash-git-prompt/gitprompt.sh" ]; then
    GIT_PROMPT_ONLY_IN_REPO=1
    source $HOME/.bash-git-prompt/gitprompt.sh
fi
" >> ~/.bashrc

echo "${GREEN}-> Configure Ansible${RESET}"
sudo mv /etc/ansible/ansible.cfg /etc/ansible/ansible.cfg-original
sudo cp configs/ansible.cfg /etc/ansible/ansible.cfg

echo "${GREEN}-> Install Telegram Desktop${RESET}"
wget https://updates.tdesktop.com/tlinux/tsetup.2.7.4.tar.xz -P /tmp/
tar -xvf /tmp/sudo apt installtsetup.2.7.4.tar.xz --directory /tmp/
sudo mv /tmp/Telegram /opt/

echo "${GREEN}-> Install docker and docker-compose${RESET}"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io
sudo groupadd docker
sudo usermod -aG docker $USER
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "${GREEN}-> Install Netbeans IDE${RESET}"
wget https://downloads.apache.org/netbeans/netbeans/12.2/Apache-NetBeans-12.2-bin-linux-x64.sh -P /tmp/
sudo sh /tmp/Apache-NetBeans-12.2-bin-linux-x64.s 

echo "${GREEN}-> Install Discord${RESET}"
wget -o discord.deb https://dl.discordapp.net/apps/linux/0.0.15/discord-0.0.15.deb -P /tmp/
sudo apt install ./tmp/discord-0.0.15.deb

echo "${GREEN}-> Install cloudflared${RESET}"
mkdir =p $HOME/.ssh
wget https://bin.equinox.io/c/VdrWdbjqyF/cloudflared-stable-linux-amd64.deb -P /tmp/
sudo dpkg -i /tmp/cloudflared-stable-linux-amd64.deb
echo "Host *.roveeb.com
        ProxyCommand /usr/local/bin/cloudflared access ssh --hostname %h
        IdentityFile /home/mateus/.ssh/mateus
" >> $HOME/.ssh/config

echo "${GREEN}-> Configure user environment${RESET}"
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
cp images/wallpaper.jpg $HOME/Pictures/Wallpapers
gsettings set org.gnome.desktop.background picture-uri "file:///$HOME/Pictures/Wallpapers/wallpaper.jpg"
mkdir -p $HOME/Projects
mkdir -p $HOME/Projects/aztec
mkdir -p $HOME/Projects/univates
mkdir -p $HOME/Projects/personal
# TODO: Configure fonts

echo "${GREEN}-> Configure pulseaudio${RESET}"
sudo echo '
### Mateus settings
load-module module-echo-cancel aec_method=webrtc sink_properties=device.description="Noise_Reduction" aec_args="analog_gain_control=0\ digital_gain_control=0"
' >> /etc/pulse/default.pa

echo "${GREEN}-> Cleanup system${RESET}"
sudo apt autoremove -y
sudo apt autoclean -y
sudo apt clean

echo "#####################"
echo "${GREEN}Post install finish${RESET}"
echo "${GREEN}Rebooting the system...${RESET}"
echo "//see you later"
echo "#####################"
sudo reboot now