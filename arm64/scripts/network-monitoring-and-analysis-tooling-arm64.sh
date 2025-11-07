set -eou pipefail
export DEBIAN_FRONTEND=noninteractive

echo "wireshark-common wireshark-common/install-setuid boolean false" | sudo debconf-set-selections

sudo apt -y install wireshark
sudo apt -y install tshark

sudo apt -y install tcpdump
sudo apt -y install net-tools

apt-get -yq install tcpreplay
apt-get -yq install hping3

# Scapy
sudo apt install -y python3-pip
sudo pip3 install --break-system-packages scapy

# tcpflow
sudo apt -y install tcpflow
