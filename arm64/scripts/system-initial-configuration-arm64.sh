apt update && apt -y upgrade
sudo -u packer env XDG_RUNTIME_DIR=/run/user/$(id -u packer) xdg-user-dirs-update

apt -y install curl wget vim
apt -y install python3 python3-pip
apt -y install git build-essential cmake libpcap-dev libboost-all-dev
apt -y install python3-magic
