#!/bin/bash

# Determine git user and email address
if [ "$1" == "" ] || [ "$2" == "" ]; then
    echo "${GREEN}Post install script to Ubuntu system based${RESET}"
    echo "Use mode: $0 gitusername gitemail"
else
    # Define git user and email
    GIT_USERNAME=$1
    GIT_EMAIL=$2
fi

GREEN=$(tput setaf 2)
RESET=$(tput sgr0)

echo "#####################"
echo "${GREEN}Post install script to Fedora system based${RESET}"
echo "#####################"

echo "${GREEN}-> Update Fedora packages${RESET}"
sudo dnf -y update

echo "${GREEN}-> Install packages for Fedora and enable RPM fusion${RESET}"
sudo dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf -y install vim \
    java-11-openjdk \
    libwebp-tools \
    neofetch \
    nextcloud-client \
    keepassxc \
    obs-studio \
    kdenlive \
    chromium \
    gnome-tweaks \
    gnome-extensions-app \
    gimp \
    audacity \
    discord \
    google-chorme \
    python3-pip
sudo python -m pip install ansible

echo "${GREEN}-> Installing Media Codecs${RESET}"
sudo dnf install gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel
sudo dnf install lame\* --exclude=lame-devel
sudo dnf group upgrade --with-optional Multimedia

echo "${GREEN}-> Configure KeePassXC${RESET}"
mkdir -p $HOME/.config/keepassxc
cp settings/keepassxc.ini $HOME/.config/keepassxc

echo "${GREEN}-> Configure git globally${RESET}"
git config --global user.email "$GIT_EMAIL"
git config --global user.name "$GIT_USERNAME"
git config --global init.defaultBranch main

echo "${GREEN}-> Configure bashrc functions${RESET}"
git clone https://github.com/magicmonty/bash-git-prompt.git ~/.bash-git-prompt --depth=1
echo "
# git-bash-prompt
if [ -f '$HOME/.bash-git-prompt/gitprompt.sh' ]; then
    GIT_PROMPT_ONLY_IN_REPO=1
    source $HOME/.bash-git-prompt/gitprompt.sh
fi

# Kill and remove all containers
function docker-clean {
        echo 'Killing...'
        docker kill $(docker ps -q)
        echo 'Removing...'
        docker rm $(docker ps -qa)
}

# PS1
export PS1='[\A] \u@\h {\w} \\$ \[$(tput sgr0)\]'

" >>~/.bashrc

echo "${GREEN}-> Install Visual Studio Code${RESET}"
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf -y check-update
sudo dnf -y install code

echo "${GREEN}-> Configure Visual Studio Code${RESET}"
mkdir -p $HOME/.config/Code/User/
cp settings/settings.json $HOME/.config/Code/User/settings.json
EXTENSIONS_FILE="settings/extensions"
EXTENSIONS_LINES=$(cat $EXTENSIONS_FILE)
for extension in $EXTENSIONS_LINES; do
    echo " * Install $extension"
    code --install-extension $extension
    echo "done..."
    echo ""
done

echo "${GREEN}-> Install Telegram Desktop${RESET}"
wget https://updates.tdesktop.com/tlinux/tsetup.3.6.1.tar.xz -O /tmp/tsetup.tar.xz
tar -xvf /tmp/tsetup.tar.xz --directory /tmp/
sudo mv /tmp/Telegram /opt/
/opt/Telegram/Telegram

echo "${GREEN}-> Install and configure Iriun Webcam${RESET}"
wget http://iriun.gitlab.io/iriunwebcam-2.3.1.deb -P /tmp/
sudo alien -r /tmp/iriunwebcam-2.3.1.deb --target=x86_64
sudo dnf -y install iriunwebcam-2.3.1.x86_64.rpm
sudo rm -rf iriunwebcam-2.3.1.x86_64.rpm
sudo modprobe v4l2loopback exclusive_caps=1

echo "${GREEN}-> Install Docker Engine and Docker Composer${RESET}"
sudo dnf -y remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine
sudo dnf -y install dnf-plugins-core
sudo dnf -y config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-compose gnome-boxes
sudo systemctl enable docker
sudo usermod -G docker -a $USER

echo "${GREEN}-> Configure OBS Studio${RESET}"
mkdir -p $HOME/.config/obs-studio/plugins
wget https://github.com/bazukas/obs-linuxbrowser/releases/download/0.6.1/linuxbrowser0.6.1-obs23.0.2-64bit.tgz -P /tmp/
tar -zxvf /tmp/linuxbrowser0.6.1-obs23.0.2-64bit.tgz -C $HOME/.config/obs-studio/plugins/
cp -r settings/obs-studio/ $HOME/.config/obs-studio/

echo "${GREEN}-> Configure Ansible${RESET}"
sudo mkdir -p /etc/ansible
sudo mv /etc/ansible/ansible.cfg /etc/ansible/ansible.cfg-original
sudo cp settings/ansible.cfg /etc/ansible/ansible.cfg

echo "${GREEN}-> Install Netbeans IDE${RESET}"
wget https://archive.apache.org/dist/netbeans/netbeans/12.5/Apache-NetBeans-12.5-bin-linux-x64.sh -O /tmp/netbeans.sh
sudo sh /tmp/netbeans.sh

echo "${GREEN}-> Install cloudflared${RESET}"
mkdir -p $HOME/.ssh
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-x86_64.rpm -P /tmp/
sudo rpm -i /tmp/cloudflared-linux-x86_64.rpm
echo "Host *.roveeb.com
        ProxyCommand /usr/local/bin/cloudflared access ssh --hostname %h
        IdentityFile /home/mateus/.ssh/mateus
" >>$HOME/.ssh/config

echo "${GREEN}-> Configure user ambient${RESET}"
echo " * Create Project path"
mkdir $HOME/Projects
mkdir -p $HOME/Projects/univates
mkdir -p $HOME/Projects/personal
mkdir -p $HOME/Projects/work
echo " * Copy Wallpappers"
mkdir -p $HOME/Pictures/Wallpapers
cp images/wallpaper.jpg $HOME/Pictures/Wallpapers
echo " * Set default theme"
gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
echo " * Set default window theme"
gsettings set org.gnome.desktop.wm.preferences theme "Adwaita-dark"
echo " * Set background"
gsettings set org.gnome.desktop.background picture-uri "file:///$HOME/Pictures/Wallpapers/wallpaper.jpg"
echo " * Set window buttons"
gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'
echo " * Install gnome extensions"
# TODO

echo "-> Install desktop apps"
echo " * Spotify via negativo17"
sudo dnf -y config-manager --add-repo=https://negativo17.org/repos/fedora-spotify.repo
sudo dnf -y install spotify-client

echo "${GREEN}-> Configure flahub${RESET}"
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "${GREEN}-> Configure fonts${RESET}"
sudo dnf install fira-code-fonts

echo "#####################"
echo "${GREEN}Post install finish${RESET}"
echo "${GREEN}Rebooting the system...${RESET}"
echo "//see you later"
echo "#####################"
sudo reboot now
