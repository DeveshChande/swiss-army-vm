set -eou pipefail
export DEBIAN_FRONTEND=noninteractive

echo "wireshark-common wireshark-common/install-setuid boolean false" | sudo debconf-set-selections

sudo apt -y install wireshark
sudo apt -y install tshark

sudo apt -y install tcpdump
sudo apt -y install net-tools

# Scapy
sudo apt install -y python3-pip
sudo pip3 install --break-system-packages scapy

# tcpflow
sudo apt -y install tcpflow

# Ngrep Installation
sudo apt install -y ngrep

# Zeek Installation
sudo apt install -y curl gnupg
curl -fsSL https://download.opensuse.org/repositories/security:zeek/Debian_12/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/security_zeek.gpg > /dev/null
echo 'deb http://download.opensuse.org/repositories/security:/zeek/Debian_12/ /' | sudo tee /etc/apt/sources.list.d/security:zeek.list

sudo apt update
sudo apt -y install zeek-lts

apt-get -yq install tcpreplay
apt-get -yq install hping3