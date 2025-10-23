set -eou pipefail
export DEBIAN_FRONTEND=noninteractive

echo "wireshark-common wireshark-common/install-setuid boolean false" | sudo debconf-set-selections

sudo apt -y install wireshark
sudo apt -y install tshark
