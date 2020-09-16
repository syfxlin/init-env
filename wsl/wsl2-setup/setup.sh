if [ ! -n "$(ip a s | grep 192.168.50.2)" ];then
    cat $HOME/.setup/set-ip.ps1 | /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe > /dev/null
fi

export WSL_HOST=192.168.50.1
export DISPLAY=$WSL_HOST:0

# 删除旧的 hosts
sudo sed -i '/#windows_ip/d' /etc/hosts
sudo sed -i "1i${WSL_HOST}   h.test   #windows_ip" /etc/hosts

# 启动 systemd
source /usr/sbin/start-systemd-namespace