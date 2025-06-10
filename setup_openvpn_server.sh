#!/bin/bash

# === 1. Update & Install ===
apt update && apt upgrade -y
apt install openvpn easy-rsa ufw iptables-persistent -y

# === 2. Setup Easy-RSA ===
make-cadir ~/openvpn-ca
cd ~/openvpn-ca
source vars
./clean-all
./build-ca --batch
./build-key-server --batch server
./build-dh
./build-key --batch client1
./build-key --batch client2

# === 3. Copy semua file ke direktori OpenVPN ===
cd ~/openvpn-ca/keys
cp ca.crt ca.key dh2048.pem server.crt server.key client1.crt client1.key /etc/openvpn/

# === 4. Buat konfigurasi server ===
cat <<EOF > /etc/openvpn/server.conf
port 1194
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh2048.pem
server 10.8.0.0 255.255.255.0
push "route 10.0.8.0 255.255.255.0"
keepalive 10 120
cipher AES-256-CBC
persist-key
persist-tun
status openvpn-status.log
verb 3
EOF

# === 5. Enable IP Forwarding ===
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
sysctl -p

# === 6. Atur iptables NAT ===
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
netfilter-persistent save

# === 7. UFW Firewall Rules ===
ufw allow ssh
ufw allow 1194/udp
ufw disable
ufw enable

# === 8. Start VPN Server ===
systemctl start openvpn@server
systemctl enable openvpn@server

echo "✅ OpenVPN Server sudah aktif!"
