#!/bin/bash
# set -v on
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
SKYBLUE='\033[0;36m'
PLAIN='\033[0m'

if [ $(uname) != "Linux" ];then
echo -e "\033[31m This script is only for Linux! \033[0m"
exit 1
fi

if [ "$LOGNAME" == "root" ]; then
    echo -e "\033[31m This script must used no-root user \033[0m"
    exit 1
fi

if [ -f /etc/redhat-release ]; then
    release="centos"
elif cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
fi

setMirrors() {
    if [ $release == "ubuntu" ];then
        sudo sed -i 's|archive.ubuntu.com|mirrors.aliyun.com|g' /etc/apt/sources.list
        sudo sed -i 's|archive.ubuntu.com|mirrors.aliyun.com|g' /etc/apt/sources.list.d/*.list
        sudo sed -i 's|cn.archive.ubuntu.com|mirrors.aliyun.com|g' /etc/apt/sources.list
        sudo sed -i 's|cn.archive.ubuntu.com|mirrors.aliyun.com|g' /etc/apt/sources.list.d/*.list
        sudo sed -i '/security.ubuntu.com/d' /etc/apt/sources.list
        sudo sed -i '/security.ubuntu.com/d' /etc/apt/sources.list.d/*.list
    elif [ $release == "debian" ];then
        sudo sed -i 's|deb.debian.org|mirrors.aliyun.com|g' /etc/apt/sources.list
        sudo sed -i 's|deb.debian.org|mirrors.aliyun.com|g' /etc/apt/sources.list.d/*.list
        sudo sed -i 's|security.debian.org/debian-security|mirrors.aliyun.com/debian-security|g' /etc/apt/sources.list
        sudo sed -i 's|security.debian.org/debian-security|mirrors.aliyun.com/debian-security|g' /etc/apt/sources.list.d/*.list
    elif [ $release == "centos" ];then
        echo "${YELLOW}This script does not support Centos replacement source!${PLAIN}"
    fi
    sudo apt update
    sudo apt upgrade -y
}

installBase() {
    sudo apt-get -y install apt-transport-https ca-certificates gnupg-agent software-properties-common
    sudo apt-get -y install gcc g++ make
    sudo apt-get -y install wget curl git
    sudo apt-get -y install htop python3 python3-pip
    sudo apt-get -y install language-pack-zh-hans
    sudo update-locale LANG=zh_CN.UTF-8
}

installZsh() {
    # 安装 zsh
    sudo apt-get -y install zsh
    sudo chsh -s /bin/zsh
    sudo sed -i 's|/bin/bash|/bin/zsh|g' /etc/passwd

    # 安装 oh-my-zsh
    sudo sed -i "1i199.232.4.133 raw.githubusercontent.com" /etc/hosts
    sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

    # 下载插件
    sudo git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
    mv zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    sudo git clone https://github.com/zsh-users/zsh-autosuggestions.git
    mv zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

    rm ~/.zshrc
    cp ./.zshrc ~/.zshrc

    # 立即生效
    source ~/.zshrc
}

installDocker() {
    sudo chmod +x ./install-docker.sh
    sudo sh ./install-docker.sh --mirror Aliyun
    sudo usermod -aG docker $USER

    # 安装 docker-compose
    sudo pip3 install docker-compose

    # 更新软件源
    sudo mkdir -p /etc/docker
    sudo cp ./daemon.json /etc/docker/daemon.json
    sudo systemctl daemon-reload
    sudo systemctl restart docker
}

installSetup() {
    sudo cp -r ./wsl2-setup $HOME/.setup

    sudo chmod +x $HOME/.setup/setup.sh

    bash ./wsl2-setup/ubuntu-wsl2-systemd-script.sh

    sudo cp ./wsl2-setup/setup /etc/sudoers.d/setup

    echo "source $HOME/.setup/setup.sh" >> $HOME/.zshrc

    source $HOME/.setup/setup.sh

    # 禁用 systemd-resolved 防止与 WSL 自动生成 resolved.conf 产生冲突
    sudo systemctl disable systemd-resolved
}

setMirrors
installBase
#installZsh
#installSetup
#installDocker
