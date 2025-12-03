set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y \
  libpam-tmpdir \
  apt-listbugs \
  needrestart \
  fail2ban \
  debsums \
  apt-show-versions \
  libpam-pwquality \
  aide \
  rkhunter \
  chkrootkit \
  acct \
  auditd \
  sysstat \
  unattended-upgrades

if [ -f /etc/fail2ban/jail.conf ] && [ ! -f /etc/fail2ban/jail.local ]; then
  cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
fi

LOGIN_DEFS="/etc/login.defs"

set_login_defs() {
  local key="$1" value="$2"
  if grep -q "^${key}" "$LOGIN_DEFS"; then
    sed -i "s/^${key}.*/${key}\t${value}/" "$LOGIN_DEFS"
  else
    echo -e "${key}\t${value}" >> "$LOGIN_DEFS"
  fi
}

set_login_defs "PASS_MAX_DAYS"  "90"
set_login_defs "PASS_MIN_DAYS"  "1"
set_login_defs "PASS_WARN_AGE"  "7"
set_login_defs "UMASK"          "027"

PWQUALITY_CONF="/etc/security/pwquality.conf"

set_pwq() {
  local key="$1" value="$2"
  if grep -q "^\s*${key}\s*=" "$PWQUALITY_CONF" 2>/dev/null; then
    sed -i "s|^\s*${key}\s*=.*|${key} = ${value}|" "$PWQUALITY_CONF"
  else
    echo "${key} = ${value}" >> "$PWQUALITY_CONF"
  fi
}

set_pwq minlen 14
set_pwq dcredit -1
set_pwq ucredit -1
set_pwq ocredit -1
set_pwq lcredit -1

COMMON_PW="/etc/pam.d/common-password"
if grep -q "pam_unix.so" "$COMMON_PW"; then
  sed -i \
    's|^\s*password\s\+\[success=1 default=ignore\]\s\+pam_unix.so.*|password [success=1 default=ignore] pam_unix.so obscure sha512 rounds=50000|' \
    "$COMMON_PW"
fi

if ! grep -q "pam_pwquality.so" "$COMMON_PW"; then
  sed -i '1i password requisite pam_pwquality.so retry=3' "$COMMON_PW"
fi

SSHD_CFG="/etc/ssh/sshd_config"

set_sshd() {
  local key="$1" value="$2"
  if grep -Eq "^[#]*\s*${key}" "$SSHD_CFG"; then
    sed -i "s/^[#]*\s*${key}.*/${key} ${value}/" "$SSHD_CFG"
  else
    echo "${key} ${value}" >> "$SSHD_CFG"
  fi
}

set_sshd "LoginGraceTime"       "30"
set_sshd "LogLevel"             "VERBOSE"
set_sshd "PermitRootLogin"      "no"
set_sshd "X11Forwarding"        "no"
set_sshd "AllowTcpForwarding"   "no"
set_sshd "ClientAliveCountMax"  "2"
set_sshd "Compression"          "no"
set_sshd "MaxAuthTries"         "3"
set_sshd "MaxSessions"          "2"
set_sshd "TCPKeepAlive"         "no"
set_sshd "AllowAgentForwarding" "no"
set_sshd "MACs" "hmac-sha2-256,hmac-sha2-512"
set_sshd "Ciphers" "chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes256-ctr"
set_sshd "KexAlgorithms" "curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group14-sha256"

systemctl reload ssh || true

cat >/etc/issue <<'EOF'
Unauthorized access to this system is prohibited.
All activity may be monitored and reported.
EOF

cp /etc/issue /etc/issue.net

cat >/etc/sysctl.d/99-hardening.conf <<'EOF'
net.ipv4.conf.all.rp_filter = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
kernel.kptr_restrict = 2
kernel.dmesg_restrict = 1
EOF

LIMITS="/etc/security/limits.conf"
if ! grep -q "^\*\s\+hard\s\+core\s\+0" "$LIMITS"; then
  echo "* hard core 0" >> "$LIMITS"
fi

RESOLV="/etc/resolv.conf"
[ -f "${RESOLV}.orig" ] || cp "$RESOLV" "${RESOLV}.orig" || true
grep -q "nameserver 1.1.1.1" "$RESOLV" || echo "nameserver 1.1.1.1" >> "$RESOLV"
grep -q "nameserver 8.8.8.8" "$RESOLV" || echo "nameserver 8.8.8.8" >> "$RESOLV"

sysctl --system || true

cat >/etc/apt/apt.conf.d/20auto-upgrades <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF

aideinit || true

systemctl enable auditd  >/dev/null 2>&1 || true
systemctl enable sysstat >/dev/null 2>&1 || true
systemctl enable acct    >/dev/null 2>&1 || true

systemctl start auditd   >/dev/null 2>&1 || true
systemctl start sysstat  >/dev/null 2>&1 || true
systemctl start acct     >/dev/null 2>&1 || true

cat >/etc/modprobe.d/blacklist-removable-storage.conf <<'EOF'
blacklist usb_storage
blacklist firewire_ohci
EOF
