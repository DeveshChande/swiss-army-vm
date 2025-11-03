# binwalk
cd /home/packer
 curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
. $HOME/.cargo/env
cd /home/packer/Downloads
git clone https://github.com/ReFirmLabs/binwalk
apt -y install build-essential libfontconfig1-dev liblzma-dev
cd binwalk
cargo build --release
cp /home/packer/Downloads/binwalk/target/release/binwalk /usr/bin/binwalk

# hashdeep
apt -y install hashdeep

# YARA
apt -y install automake libtool make gcc pkg-config
cd /home/packer/Downloads
sudo curl -fLO https://github.com/VirusTotal/yara/archive/refs/tags/v4.5.5.tar.gz
sudo tar -xzf v4.5.5.tar.gz
cd /home/packer/Downloads/yara-4.5.5
sudo ./bootstrap.sh
sudo ./configure
sudo make
sudo make install
cp /home/packer/Downloads/yara-4.5.5/yara /usr/bin

# GDB
apt -y install gdb