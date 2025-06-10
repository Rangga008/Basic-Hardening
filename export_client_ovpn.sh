#!/bin/bash

# Pastikan semua file ada
CLIENT_NAME="client1"
OUTPUT_FILE="${CLIENT_NAME}.ovpn"

cat <<EOF > $OUTPUT_FILE
client
dev tun
proto udp
remote [IP-VPN-SERVER] 1194
resolv-retry infinite
nobind
persist-key
persist-tun
cipher AES-256-CBC
verb 3
<ca>
$(cat /etc/openvpn/ca.crt)
</ca>
<cert>
$(cat /etc/openvpn/${CLIENT_NAME}.crt)
</cert>
<key>
$(cat /etc/openvpn/${CLIENT_NAME}.key)
</key>
EOF

echo "✅ File konfigurasi client ada di: $OUTPUT_FILE"
