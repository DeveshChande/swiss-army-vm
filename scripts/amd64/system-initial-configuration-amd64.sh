apt update && apt -y upgrade
sudo -u packer env XDG_RUNTIME_DIR=/run/user/$(id -u packer) xdg-user-dirs-update

apt -y install curl wget vim
apt -y install python3 python3-pip
apt -y install git build-essential cmake libpcap-dev libboost-all-dev
apt -y install python3-magic

# Cyberchef Installation
cd /home/packer/Downloads
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
nvm install v18.0.0
git clone https://github.com/gchq/CyberChef.git
# cd CyberChef
# sudo chown -R 1000:1000 "/home/packer/.npm"
# npm install 18.20.8
# npm audit fix
# npm audit fix
# Run npm start from inside the CyberChef directory to execute a local instance.
