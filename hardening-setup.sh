#!/bin/bash

# 🧼 Update sistem
echo "[1/10] Updating system..."
apt update && apt upgrade -y

# 🔥 Install dasar
echo "[2/10] Installing required packages..."
apt install -y curl wget gnupg2 lsb-release unzip git ufw sudo net-tools iputils-ping ssh build-essential \
libpcap-dev libpcre3-dev libdumbnet-dev bison flex zlib1g-dev liblzma-dev openssl libssl-dev libnghttp2-dev \
libdnet autoconf libtool libjansson-dev libuuid1 pkg-config cmake libnetfilter-queue-dev

# 🧱 Enable & config UFW
echo "[3/10] Setting up UFW Firewall..."
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 1194/udp # OpenVPN default port
ufw enable

# 🔐 Disable SSH root login
echo "[4/10] Disabling SSH root login..."
sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl restart sshd

# 🌀 Setup OpenVPN (angristan)
echo "[5/10] Installing OpenVPN via angristan script..."
curl -O https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
chmod +x openvpn-install.sh
echo "OpenVPN script ready. Run './openvpn-install.sh' manually to configure interactively."

# 🐍 Install DAQ untuk Snort
echo "[6/10] Installing DAQ for Snort..."
cd /tmp
wget https://www.snort.org/downloads/snort/daq-3.0.11.tar.gz
tar -xvzf daq-3.0.11.tar.gz
cd daq-3.0.11
./configure && make && make install

# 🧠 Install Snort 3
echo "[7/10] Installing Snort 3..."
cd /tmp
wget https://www.snort.org/downloads/snort/snort3-3.1.67.0.tar.gz
tar -xvzf snort3-3.1.67.0.tar.gz
cd snort3-3.1.67.0
./configure_cmake.sh --prefix=/usr/local/snort
cd build
make -j"$(nproc)"
make install

# 🔗 PATH fix
echo 'export PATH=$PATH:/usr/local/snort/bin' >> ~/.bashrc
source ~/.bashrc

# 📁 Setup folder Snort
echo "[8/10] Setting up Snort directories..."
mkdir -p /usr/local/snort/etc/rules
mkdir -p /usr/local/snort/etc/so_rules
mkdir -p /usr/local/snort/etc/lua
mkdir -p /var/log/snort
touch /usr/local/snort/etc/rules/local.rules

# 📝 Config Snort rules
echo '[9/10] Writing default local.rules...'
echo 'alert icmp any any -> any any (msg:"Ping Detected"; sid:1000001; rev:1;)' > /usr/local/snort/etc/rules/local.rules

# 🔄 Copy default config
cp /tmp/snort3-3.1.67.0/etc/snort.lua /usr/local/snort/etc/
cp /tmp/snort3-3.1.67.0/etc/*.rules /usr/local/snort/etc/rules/

# ✅ Final test reminder
echo "[10/10] DONE! 🎉"
echo ""
echo "To run Snort, use:"
echo "sudo snort -c /usr/local/snort/etc/snort.lua -R /usr/local/snort/etc/rules/local.rules -i eth0 -A alert_fast"
echo ""
echo "To install OpenVPN, run:"
echo "sudo ./openvpn-install.sh"
echo ""
echo "UFW enabled, SSH root login disabled. Stay safe, hacker love~ 🖤"
