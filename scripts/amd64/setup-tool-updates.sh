#!/bin/bash
set -euo pipefail

# This script runs ONCE during Packer build.
# It installs a weekly cron job that keeps non-APT tools updated.

INSTALL_PATH="/etc/cron.weekly/tool-updates"

# Create the weekly update script
cat > "$INSTALL_PATH" << 'EOF'
#!/bin/bash
set -euo pipefail

LOG_FILE="/var/log/tool-updates.log"

mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

{
  echo "===== Tool update run: $(date -Iseconds) ====="

  update_git_repo() {
    local dir="$1"
    if [ -d "$dir/.git" ]; then
      echo "[*] Updating git repo in $dir"
      git -C "$dir" pull --ff-only || echo "[!] git pull failed in $dir"
    fi
  }

  echo "[*] Updating non-APT security tools..."

  
  # 1) Lynis
  
  if command -v lynis >/dev/null 2>&1; then
    echo "[-] Updating lynis data..."
    lynis update info || echo "[!] lynis update failed"
  fi

  
  # 2) Nuclei engine + templates
  
  if command -v nuclei >/dev/null 2>&1; then
    echo "[-] Updating nuclei engine/templates..."
    nuclei -update || echo "[!] nuclei engine update failed"
    nuclei -update-templates || echo "[!] nuclei template update failed"
  fi

  # Git-based Nuclei template sync 
  NUCLEI_TEMPLATES_DIR="/home/packer/nuclei-templates"
  update_git_repo "$NUCLEI_TEMPLATES_DIR"

  
  # 3) CloudSploit (git + npm)
  
  CLOUDSPLOIT_DIR="/home/packer/Downloads/cloudsploit"
  if [ -d "$CLOUDSPLOIT_DIR/.git" ]; then
    echo "[-] Updating Cloudsploit..."
    git -C "$CLOUDSPLOIT_DIR" pull --ff-only || echo "[!] Cloudsploit git pull failed"
    npm --prefix "$CLOUDSPLOIT_DIR" install || echo "[!] Cloudsploit npm install failed"
  fi

  
  # 4) Prowler (via docker-compose)
  
  PROWLER_DIR="/home/packer/Downloads/prowler"
  if [ -d "$PROWLER_DIR" ] && command -v docker >/dev/null 2>&1; then
    echo "[-] Updating Prowler docker images..."
    (cd "$PROWLER_DIR" && docker compose pull) || echo "[!] Prowler docker compose pull failed"
  fi

  
  # 5) Nikto (inside Prowler repo)
  
  NIKTO_DIR="/home/packer/Downloads/prowler/nikto"
  update_git_repo "$NIKTO_DIR"

  
  # 6) Binwalk
  
  for BINWALK_DIR in "/home/packer/Downloads/binwalk" "/opt/binwalk"; do
    if [ -d "$BINWALK_DIR/.git" ]; then
      echo "[-] Updating Binwalk in $BINWALK_DIR..."
      git -C "$BINWALK_DIR" pull --ff-only || echo "[!] Binwalk git pull failed"
      if command -v cargo >/dev/null 2>&1; then
        cargo build --manifest-path "$BINWALK_DIR/Cargo.toml" --release || echo "[!] Binwalk cargo build failed"
        cp "$BINWALK_DIR/target/release/binwalk" /usr/bin/binwalk || echo "[!] Failed to update Binwalk binary"
      fi
      break
    fi
  done

  
  # 7) Volatility3
  
  VOL3_DIR=""
  for d in "/home/packer/volatility3" "/home/packer/Downloads/volatility3" "/root/volatility3" "/volatility3"; do
    if [ -d "$d/.git" ]; then
      VOL3_DIR="$d"
      break
    fi
  done

  if [ -n "${VOL3_DIR:-}" ]; then
    echo "[-] Updating Volatility3 in $VOL3_DIR..."
    git -C "$VOL3_DIR" pull --ff-only || echo "[!] Volatility3 git pull failed"

    VENV_CANDIDATES=(
      "/home/packer/vol3-venv"
      "$(dirname "$VOL3_DIR")/vol3-venv"
    )

    for VENV_DIR in "${VENV_CANDIDATES[@]}"; do
      if [ -x "$VENV_DIR/bin/pip" ]; then
        if [ -f "$VOL3_DIR/requirements.txt" ]; then
          "$VENV_DIR/bin/pip" install -r "$VOL3_DIR/requirements.txt" || echo "[!] Volatility3 pip install failed"
        else
          "$VENV_DIR/bin/pip" install "$VOL3_DIR" || echo "[!] Volatility3 install failed"
        fi
        break
      fi
    done
  fi

  
  # 8) Dumpzilla & RegRipper
  
  update_git_repo "/opt/dumpzilla"
  update_git_repo "/opt/regripper"

  
  # 9) Python pip tools
  
  if command -v pip3 >/dev/null 2>&1; then
    echo "[-] Updating plaso (log2timeline) and scapy..."
    pip3 install --break-system-packages --upgrade plaso scapy || echo "[!] pip upgrade failed"
  fi

  echo "[*] Tool update run complete."

} >> "$LOG_FILE" 2>&1
EOF

# Permissions so cron can execute
chmod 755 "$INSTALL_PATH"

# Ensure cron is installed and enabled
apt-get update -y
apt-get install -y cron
systemctl enable cron
systemctl start cron
