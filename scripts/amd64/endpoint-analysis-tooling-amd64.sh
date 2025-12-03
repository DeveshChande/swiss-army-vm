set -eou pipefail

# Velociraptor Installation
sudo wget "https://github.com/Velocidex/velociraptor/releases/download/v0.75/velociraptor-v0.75.4-linux-amd64" -O /usr/local/bin/velociraptor && sudo chmod +755 /usr/local/bin/velociraptor

# OSQuery Installation
wget "https://pkg.osquery.io/deb/osquery_5.19.0-1.linux_amd64.deb" && apt install ./osquery_5.19.0-1.linux_amd64.deb

# evtx
sudo curl -fL -o /usr/bin/evtx-dump https://github.com/omerbenamram/evtx/releases/download/v0.9.0/evtx_dump-v0.9.0-x86_64-unknown-linux-gnu
sudo chmod +x /usr/bin/evtx-dump

# Volatility3 Installation
apt-get install -yq python3 python3-pip python3-venv git
git clone https://github.com/volatilityfoundation/volatility3.git
python3 -m venv ./vol3-venv
./vol3-venv/bin/pip install --upgrade pip
if [ -f "./volatility3/requirements.txt" ]; then
./vol3-venv/bin/pip install -r ./volatility3/requirements.txt
else
./vol3-venv/bin/pip install ./volatility3
fi

# ExifTool Installation
sudo apt install -y libimage-exiftool-perl

# RegRipper Installation
sudo apt-get install -y perl libparse-win32registry-perl git
cd /opt
sudo git clone https://github.com/keydet89/RegRipper3.0.git regripper
sudo chmod +x /opt/regripper/rip.pl
sudo sed -i '1s|.*|#!/usr/bin/perl|' /opt/regripper/rip.pl
sudo tee /usr/local/bin/rip > /dev/null << 'EOF'
#!/bin/bash
cd /opt/regripper && ./rip.pl "$@"
EOF
  
sudo chmod +x /usr/local/bin/rip

# Log2timeline Installation
sudo pip3 install --break-system-packages plaso

# Create python symlink for compatibility
sudo ln -sf /usr/bin/python3 /usr/bin/python

# Dumpzilla Installation
cd /opt
sudo git clone https://github.com/Busindre/dumpzilla.git
sudo chmod +x /opt/dumpzilla/dumpzilla.py
sudo ln -sf /opt/dumpzilla/dumpzilla.py /usr/local/bin/dumpzilla
