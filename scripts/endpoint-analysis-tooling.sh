set -eou pipefail

# Velociraptor Installation
sudo wget "https://github.com/Velocidex/velociraptor/releases/download/v0.75/velociraptor-v0.75.4-linux-amd64" -O /usr/local/bin/velociraptor && sudo chmod +755 /usr/local/bin/velociraptor

# OSQuery Installation
wget "https://pkg.osquery.io/deb/osquery_5.19.0-1.linux_amd64.deb" && apt install ./osquery_5.19.0-1.linux_amd64.deb

# evtx
sudo curl -fL -o /usr/bin/evtx-dump https://github.com/omerbenamram/evtx/releases/download/v0.9.0/evtx_dump-v0.9.0-x86_64-unknown-linux-gnu
sudo chmod +x /usr/bin/evtx-dump
