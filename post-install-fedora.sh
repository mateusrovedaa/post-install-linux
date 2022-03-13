#!/bin/bash

# Determine git user and email address
if [ "$1" == ""  ] || [ "$2" == "" ] ; then
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
echo "${GREEN}Post install script to Fedora system based${RESET}"
echo "#####################"

echo "${GREEN}-> Update Fedora packages${RESET}"
sudo dnf -y update

echo "${GREEN}-> Install packages for Fedora and enable RPM fusion${RESET}"
sudo dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf -y install vim \
default-jdk \
libwebp-tools \
neofetch \
nextcloud-desktop \
keepassxc \
virtualbox \
virtualbox-ext-pack \
obs-studio \
kdenlive \
chromium-browser \
gnome-tweaks \
gnome-extensions-app \
gimp \ 
audacity \
discord
sudo python get-pip.py
sudo python -m pip install ansible

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
if [ -f "$HOME/.bash-git-prompt/gitprompt.sh" ]; then
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
" >> ~/.bashrc

echo "${GREEN}-> Install Visual Studio Code${RESET}"
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf -y check-update
sudo dnf -y install code

echo "${GREEN}-> Configure Visual Studio Code${RESET}"
mkdir -p $HOME/.config/Code/User/
cp settings/settings.json $HOME/.config/Code/User/settings.json
EXTENSIONS_FILE="settings/extensions"
EXTENSIONS_LINES=`cat $EXTENSIONS_FILE`
for extension in $EXTENSIONS_LINES; do
    echo " * Install $extension"
    code --install-extension $extension
    echo "done..."
    echo ""
done

echo "${GREEN}-> Install Telegram Desktop${RESET}"
wget https://updates.tdesktop.com/tlinux/tsetup.2.7.4.tar.xz -P /tmp/
tar -xvf /tmp/tsetup.2.7.4.tar.xz --directory /tmp/
sudo mv /tmp/Telegram /opt/

echo "${GREEN}-> Install v4l2loopback from sentry/v4l2loopback${RESET}"
sudo dnf -y copr enable sentry/v4l2loopback
sudo dnf -y install v4l2loopback
sudo dnf -y install v4l2loopback-dkms

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
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-compose
sudo systemctl enable docker
sudo usermod -G docker -a $USER

echo "${GREEN}-> Configure OBS Studio${RESET}"
mkdir -p $HOME/.config/obs-studio/plugins
wget https://github.com/bazukas/obs-linuxbrowser/releases/download/0.6.1/linuxbrowser0.6.1-obs23.0.2-64bit.tgz -P /tmp/
tar -zxvf /tmp/linuxbrowser0.6.1-obs23.0.2-64bit.tgz -C $HOME/.config/obs-studio/plugins/
cp -r settings/obs-studio/ $HOME/.config/obs-studio/

echo "${GREEN}-> Configure Ansible${RESET}"
sudo mv /etc/ansible/ansible.cfg /etc/ansible/ansible.cfg-original
sudo cp settings/ansible.cfg /etc/ansible/ansible.cfg

echo "${GREEN}-> Install Netbeans IDE${RESET}"
wget https://downloads.apache.org/netbeans/netbeans/12.4/Apache-NetBeans-12.4-bin-linux-x64.sh -P /tmp/
sudo sh /tmp/Apache-NetBeans-12.4-bin-linux-x64.sh

echo "${GREEN}-> Install cloudflared${RESET}"
mkdir -p $HOME/.ssh
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-x86_64.rpm -P /tmp/
sudo rpm -i /tmp/cloudflared-linux-x86_64.rpm
echo "Host *.roveeb.com
        ProxyCommand /usr/local/bin/cloudflared access ssh --hostname %h
        IdentityFile /home/mateus/.ssh/mateus
" >> $HOME/.ssh/config

echo "${GREEN}-> Configure user ambient${RESET}"
echo " * Create Project path"
mkdir $HOME/Projects
mkdir -p $HOME/Projects/univates
mkdir -p $HOME/Projects/personal
echo " * Copy Wallpappers"
mkdir -p $HOME/Imagens/Wallpapers
cp images/wallpaper.jpg $HOME/Imagens/Wallpapers
echo " * Set default theme"
gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
echo " * Set default window theme"
gsettings set org.gnome.desktop.wm.preferences theme "Adwaita-dark"
echo " * Set background"
gsettings set org.gnome.desktop.background picture-uri "file:///$HOME/Imagens/Wallpapers/wallpaper.jpg"

echo "-> Install desktop apps"
echo " * Evolution Email Client"
sudo dnf -y evolution
echo " * Spotify via negativo17"
sudo dnf -y config-manager --add-repo=https://negativo17.org/repos/fedora-spotify.repo
sudo dnf -y install spotify-client

echo "${GREEN}-> Configure fonts${RESET}"
dnf install fira-code-fonts

echo "#####################"
echo "${GREEN}Post install finish${RESET}"
echo "${GREEN}Rebooting the system...${RESET}"
echo "//see you later"
echo "#####################"
sudo reboot now